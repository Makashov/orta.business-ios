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
    /// Per-bucket counts from `GET /orders/counts`, scoped by the current search + date range
    /// (but not by `statusFilter` itself, so every chip's count stays visible).
    @State private var statusBucketCounts: [OrderStatusFilter: Int] = [:]
    /// Per-preset totals for the date sheet, scoped by date only (matches the sheet's original,
    /// search/status-independent badges).
    @State private var datePresetCounts: [OrderDatePreset: Int] = [:]

    private let calendar = Calendar.current
    private let ordersService: any OrdersServicing = LiveOrdersService()

    /// Drives a refetch of `orders` whenever any part of the active filter changes.
    private struct OrdersFilterKey: Equatable {
        let query: String
        let from: Date?
        let to: Date?
        let statusFilter: OrderStatusFilter
    }

    /// Drives a refetch of `statusBucketCounts`; deliberately excludes `statusFilter`.
    private struct CountsFilterKey: Equatable {
        let query: String
        let from: Date?
        let to: Date?
    }

    var body: some View {
        VStack(spacing: 0) {
            OrdersHeaderView(searchText: $searchText, isSearching: $isSearching)

            OrderDateFilterButtonView(label: dateLabel, subLabel: dateSubLabel) {
                isDateSheetPresented = true
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            OrderStatusFilterChipsView(selection: $statusFilter, counts: { statusBucketCounts[$0] ?? 0 })
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
#if os(iOS)
            .listRowSpacing(8)
#endif
            .scrollContentBackground(.hidden)
            .refreshable {
                await loadOrders()
                await loadStatusBucketCounts()
            }
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
        .task(id: ordersFilterKey) {
            if isSearching && !activeQuery.isEmpty {
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
            }
            await statusStore?.load()
            await loadOrders()
        }
        .task(id: countsFilterKey) {
            if isSearching && !activeQuery.isEmpty {
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
            }
            await loadStatusBucketCounts()
        }
        .task(id: isDateSheetPresented) {
            guard isDateSheetPresented else { return }
            await loadDatePresetCounts()
        }
        .sheet(isPresented: $isDateSheetPresented) {
            OrderDateFilterSheetView(
                preset: $datePreset,
                customFrom: $customFrom,
                customTo: $customTo,
                counts: { datePresetCounts[$0] ?? 0 },
                shownCount: filteredOrders.count,
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

    private var ordersFilterKey: OrdersFilterKey {
        let (from, to) = activeDateRange
        return OrdersFilterKey(query: activeQuery, from: from, to: to, statusFilter: statusFilter)
    }

    private var countsFilterKey: CountsFilterKey {
        let (from, to) = activeDateRange
        return CountsFilterKey(query: activeQuery, from: from, to: to)
    }

    // MARK: - Loading

    private func loadOrders() async {
        let (from, to) = activeDateRange
        let statusIDs = statusFilter == .all ? nil : statusStore?.statuses.filter(statusFilter.matches).map(\.id)
        do {
            let dtos = try await ordersService.fetchOrders(
                query: activeQuery.isEmpty ? nil : activeQuery,
                from: from,
                till: to,
                statusIDs: statusIDs,
                limit: nil
            )
            orders = dtos.map { dto in
                Order(dto: dto, status: statusStore?.status(id: dto.status) ?? .canceled)
            }
            loadError = nil
        } catch {
            loadError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    /// Per-status-bucket counts scoped by the active search + date range, from `GET /orders/counts`.
    private func loadStatusBucketCounts() async {
        guard let statuses = statusStore?.statuses else { return }
        let (from, to) = activeDateRange
        guard let counts = try? await ordersService.fetchOrderCounts(
            query: activeQuery.isEmpty ? nil : activeQuery,
            from: from,
            till: to
        ) else { return }

        statusBucketCounts = Dictionary(
            uniqueKeysWithValues: OrderStatusFilter.allCases.map { filter in
                let total = statuses.filter(filter.matches).reduce(0) { $0 + (counts[$1.name] ?? 0) }
                return (filter, total)
            }
        )
    }

    /// Per-date-preset totals (search/status-independent, matching the sheet's original badges),
    /// fetched in parallel via `GET /orders/counts`.
    private func loadDatePresetCounts() async {
        let presets = OrderDatePreset.allCases.filter { $0 != .custom }
        let results = await withTaskGroup(of: (OrderDatePreset, Int).self) { group in
            for preset in presets {
                group.addTask {
                    let (from, to) = preset.range(referenceDate: .now, calendar: calendar)
                    let counts = (try? await ordersService.fetchOrderCounts(query: nil, from: from, till: to)) ?? [:]
                    return (preset, counts.values.reduce(0, +))
                }
            }
            var results: [OrderDatePreset: Int] = [:]
            for await (preset, total) in group {
                results[preset] = total
            }
            return results
        }
        datePresetCounts = results
    }

    // MARK: - Date filtering

    private var activeDateRange: (from: Date?, to: Date?) {
        datePreset == .custom ? (customFrom, customTo) : datePreset.range(referenceDate: .now, calendar: calendar)
    }

    private func matches(_ order: Order, from: Date?, to: Date?) -> Bool {
        guard from != nil || to != nil else { return true }
        // An unscheduled order has no date to check, so it can't match a specific range.
        guard let scheduledAt = order.scheduledAt else { return false }
        if let from, scheduledAt < from { return false }
        if let to {
            let exclusiveEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to))!
            if scheduledAt >= exclusiveEnd { return false }
        }
        return true
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

    // Preserves the order the backend returned (newest first), rather than re-sorting.
    private var filteredOrders: [Order] {
        dateAndSearchFilteredOrders
            .filter { statusFilter.matches($0.status) }
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
