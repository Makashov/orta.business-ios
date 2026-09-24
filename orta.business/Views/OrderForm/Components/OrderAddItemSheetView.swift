//
//  OrderAddItemSheetView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderAddItemSheetView: View {
    private enum Step {
        case catalog, configure
    }

    let catalogItems: [CatalogItem]
    var existingItem: OrderLineItem?
    var onSave: (OrderLineItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var step: Step
    @State private var searchText = ""
    @State private var activeCatalogItem: CatalogItem?

    @State private var isCustom: Bool
    @State private var name: String
    @State private var quantity: Int
    @State private var unitPrice: Int
    @State private var unit: String
    @State private var comment: String

    init(catalogItems: [CatalogItem], existingItem: OrderLineItem? = nil, onSave: @escaping (OrderLineItem) -> Void) {
        self.catalogItems = catalogItems
        self.existingItem = existingItem
        self.onSave = onSave
        _step = State(initialValue: existingItem == nil ? .catalog : .configure)
        _isCustom = State(initialValue: existingItem?.catalogItemId == nil)
        _activeCatalogItem = State(initialValue: catalogItems.first { $0.id == existingItem?.catalogItemId })
        _name = State(initialValue: existingItem?.name ?? "")
        _quantity = State(initialValue: existingItem?.quantity ?? 1)
        _unitPrice = State(initialValue: existingItem?.unitPrice ?? 0)
        _unit = State(initialValue: existingItem?.unit ?? "шт")
        _comment = State(initialValue: existingItem?.comment ?? "")
    }

    var body: some View {
        Group {
            switch step {
            case .catalog: catalogStep
            case .configure: configureStep
            }
        }
    }

    // MARK: - Step 1: catalog

    private var filteredCatalogItems: [CatalogItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return catalogItems }
        return catalogItems.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    private var catalogStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Text("Каталог")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Button {
                        isCustom = true
                        name = ""
                        quantity = 1
                        unitPrice = 0
                        unit = "шт"
                        comment = ""
                        step = .configure
                    } label: {
                        Text("Своя позиция")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.brandAccent)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.tertiary)

                    TextField("Название услуги или товара", text: $searchText)
                        .font(.system(size: 14, weight: .medium))
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 11)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color("Card2"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .strokeBorder(Color("Line"))
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Часто выбирают")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.4)
                        .textCase(.uppercase)
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 8)

                    VStack(spacing: 8) {
                        ForEach(filteredCatalogItems) { item in
                            catalogItemRow(item)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 26)
            }
        }
    }

    private func catalogItemRow(_ item: CatalogItem) -> some View {
        Button {
            selectCatalogItem(item)
        } label: {
            HStack(spacing: 11) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(item.unitPrice.map { "\($0.formatted()) ₸ / \(item.unitCode)" } ?? "Цена согласуется / \(item.unitCode)")
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("Card2"))
            )
        }
        .buttonStyle(.plain)
    }

    private func selectCatalogItem(_ item: CatalogItem) {
        activeCatalogItem = item
        isCustom = false
        name = item.name
        unitPrice = item.unitPrice ?? 0
        unit = item.unitCode
        quantity = 1
        comment = ""
        step = .configure
    }

    // MARK: - Step 2: configure

    private var configureSubtitle: String? {
        guard let activeCatalogItem else { return nil }
        guard let basePrice = activeCatalogItem.unitPrice else { return "Базовая цена согласуется" }
        return "Базовая цена \(basePrice.formatted()) ₸"
    }

    private var configureStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        if isCustom {
                            TextField("Название позиции", text: $name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                        } else {
                            Text(name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                        }

                        if let configureSubtitle {
                            Text(configureSubtitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer(minLength: 8)

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color("Card2"))
                            )
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Количество")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.4)
                                .textCase(.uppercase)
                                .foregroundStyle(.tertiary)
                            Text(verbatim: "\(quantity) \(unit)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            stepperButton(systemImage: "minus", isProminent: false) {
                                if quantity > 1 { quantity -= 1 }
                            }
                            .disabled(quantity <= 1)

                            Text("\(quantity)")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.primary)
                                .frame(minWidth: 26)

                            stepperButton(systemImage: "plus", isProminent: true) {
                                quantity += 1
                            }
                        }
                    }
                    .padding(.bottom, 12)

                    Divider()

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Цена за шт, ₸")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.4)
                                .textCase(.uppercase)
                                .foregroundStyle(.tertiary)
                            TextField("0", value: $unitPrice, format: .number)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                                .keyboardType(.numberPad)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)

                    Divider()

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Комментарий к позиции")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.4)
                            .textCase(.uppercase)
                            .foregroundStyle(.tertiary)
                        TextField("Например: 3-местный, светлая ткань", text: $comment)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("Card2"))
                )

                HStack {
                    Text("Сумма позиции")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(verbatim: "\(lineTotal.formatted()) ₸")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 4)

                Button {
                    save()
                } label: {
                    Text(existingItem == nil ? "Добавить в заказ" : "Сохранить")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("AccentLabel"))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(canSave ? Color.brandAccent : Color.brandAccent.opacity(0.4))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
            }
            .padding(16)
        }
    }

    private var lineTotal: Int { quantity * unitPrice }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func stepperButton(systemImage: String, isProminent: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isProminent ? Color("AccentLabel") : Color.secondary)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isProminent ? Color.brandAccent : Color("Card"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(isProminent ? Color.clear : Color("Line"))
                )
        }
        .buttonStyle(.plain)
    }

    private func save() {
        // Custom items have no catalog default to compare against, and a catalog
        // item whose base price the user changed both count as "manually agreed".
        let priceAgreed = isCustom || activeCatalogItem?.unitPrice == nil || activeCatalogItem?.unitPrice != unitPrice
        let item = OrderLineItem(
            id: existingItem?.id ?? UUID(),
            catalogItemId: isCustom ? nil : (activeCatalogItem?.id ?? existingItem?.catalogItemId),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            unitPrice: unitPrice,
            unit: unit,
            priceAgreed: priceAgreed,
            comment: comment
        )
        onSave(item)
        dismiss()
    }
}

extension View {
    /// Presents the catalog → configure add/edit-item flow. Shared by the order
    /// create and edit forms so both stay in sync with one implementation.
    func orderAddItemSheet(
        isPresented: Binding<Bool>,
        catalogItems: [CatalogItem],
        editingItem: OrderLineItem?,
        onSave: @escaping (OrderLineItem) -> Void
    ) -> some View {
        sheet(isPresented: isPresented) {
            OrderAddItemSheetView(catalogItems: catalogItems, existingItem: editingItem, onSave: onSave)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }
}

#Preview("Catalog") {
    OrderAddItemSheetView(catalogItems: CatalogItem.sample) { _ in }
}

#Preview("Configure") {
    OrderAddItemSheetView(
        catalogItems: CatalogItem.sample,
        existingItem: OrderLineItem(name: "Химчистка дивана", quantity: 1, unitPrice: 12_000, unit: "шт", comment: "3-местный")
    ) { _ in }
}
