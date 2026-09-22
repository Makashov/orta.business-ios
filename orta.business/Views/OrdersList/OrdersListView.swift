import SwiftUI

struct OrdersListView: View {
    @Environment(OrderStatusStore.self) private var statusStore: OrderStatusStore?

    @State private var searchText = ""
    @State private var isSearching = false
    @State private var orders: [Order] = []
    @State private var loadError: String?
    @State private var datePreset: OrderDatePreset = .all
    @State private var customFrom: Date?
    @State private var customTo: Date?
    @State private var isDateSheetPresented = false
    @State private var statusFilter: OrderStatusFilter = .all
    @State private var selectedOrder: Order?

    private let calendar = Calendar.current
    private let ordersService: any OrdersServicing = LiveOrdersService()

    var body: some View {
        VStack(spacing: 0) {
            OrdersHeaderView(searchText: $searchText, isSearching: $isSearching)

            OrderDateFilterButtonView(label: dateLabel, subLabel: dateSubLabel) {
                isDateSheetPresented = true
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            OrderStatusFilterChipsView(selection: $statusFilter, counts: statusCount(for:))
                .padding(.bottom, 12)

            List {
                ForEach(filteredOrders) { order in
                    Button {
                        selectedOrder = order
                    } label: {
                        OrderListItemView(order: order)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .orderSwipeActions(for: order, orders: $orders, statuses: statusStore?.statuses ?? [])
                }
            }
            .listStyle(.plain)
            .listRowSpacing(8)
            .scrollContentBackground(.hidden)
            .overlay {
                if filteredOrders.isEmpty {
                    Text(emptyStateText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 70)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .appBackground()
        .navigationDestination(item: $selectedOrder) { order in
            OrderDetailsView(order: order)
        }
        .task {
            await statusStore?.load()
            await loadOrders()
        }
        .sheet(isPresented: $isDateSheetPresented) {
            OrderDateFilterSheetView(
                preset: $datePreset,
                customFrom: $customFrom,
                customTo: $customTo,
                counts: count(for:),
                shownCount: dateFilteredOrders.count,
                onReset: {
                    datePreset = .all
                    customFrom = nil
                    customTo = nil
                },
                onApply: {
                    isDateSheetPresented = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }

    // MARK: - Loading

    private func loadOrders() async {
        do {
            let dtos = try await ordersService.fetchOrders()
            orders = dtos.map { dto in
                Order(dto: dto, status: statusStore?.status(id: dto.status) ?? .canceled)
            }
            loadError = nil
        } catch {
            loadError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    // MARK: - Date filtering

    private var activeDateRange: (from: Date?, to: Date?) {
        datePreset == .custom ? (customFrom, customTo) : datePreset.range(referenceDate: .now, calendar: calendar)
    }

    private func matches(_ order: Order, from: Date?, to: Date?) -> Bool {
        if let from, order.date < from { return false }
        if let to {
            let exclusiveEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to))!
            if order.date >= exclusiveEnd { return false }
        }
        return true
    }

    private var dateFilteredOrders: [Order] {
        let (from, to) = activeDateRange
        return orders.filter { matches($0, from: from, to: to) }
    }

    private func count(for preset: OrderDatePreset) -> Int {
        let (from, to) = preset.range(referenceDate: .now, calendar: calendar)
        return orders.filter { matches($0, from: from, to: to) }.count
    }

    // MARK: - Search + status filtering

    private var activeQuery: String {
        isSearching ? searchText.trimmingCharacters(in: .whitespacesAndNewlines) : ""
    }

    private func hits(_ order: Order, query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let q = query.lowercased()
        let digits = q.filter(\.isNumber)
        let phoneDigits = order.phone.filter(\.isNumber)
        return String(order.id).contains(q)
            || order.name.lowercased().contains(q)
            || order.address.lowercased().contains(q)
            || (digits.count >= 3 && phoneDigits.contains(digits))
    }

    /// Orders filtered by the active date range and search query, but not by status.
    private var dateAndSearchFilteredOrders: [Order] {
        let (from, to) = activeDateRange
        let query = activeQuery
        return orders.filter { matches($0, from: from, to: to) && hits($0, query: query) }
    }

    private func statusCount(for filter: OrderStatusFilter) -> Int {
        dateAndSearchFilteredOrders.filter { filter.matches($0.status) }.count
    }

    private var filteredOrders: [Order] {
        dateAndSearchFilteredOrders
            .filter { statusFilter.matches($0.status) }
            .sorted { $0.date > $1.date }
    }

    private var emptyStateText: String {
        if let loadError { return loadError }
        return activeQuery.isEmpty
            ? "Заказов в этой категории нет"
            : "Ничего не найдено — проверьте номер или телефон"
    }

    private func human(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }

    private var dateLabel: String {
        if datePreset == .custom {
            if let from = customFrom, let to = customTo { return "\(human(from)) – \(human(to))" }
            if let from = customFrom { return "с \(human(from))" }
            if let to = customTo { return "по \(human(to))" }
            return OrderDatePreset.custom.label
        }
        return datePreset.label
    }

    private var dateSubLabel: String {
        let (from, to) = activeDateRange
        guard from != nil || to != nil else { return "Все даты" }
        if let from, let to {
            return calendar.isDate(from, inSameDayAs: to) ? human(from) : "\(human(from)) – \(human(to))"
        }
        if let from { return "с \(human(from))" }
        if let to { return "по \(human(to))" }
        return "Все даты"
    }
}

#Preview {
    OrdersListView()
}
