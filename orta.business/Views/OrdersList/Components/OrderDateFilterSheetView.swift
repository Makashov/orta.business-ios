//
//  OrderDateFilterSheetView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

import SwiftUI

struct OrderDateFilterSheetView: View {
    @Binding var preset: OrderDatePreset
    @Binding var customFrom: Date?
    @Binding var customTo: Date?
    var counts: (OrderDatePreset) -> Int
    let shownCount: Int
    var onReset: () -> Void = {}
    var onApply: () -> Void = {}

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Период")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 12)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(OrderDatePreset.allCases) { presetOption in
                        presetButton(presetOption)
                    }
                }

                VStack(alignment: .leading, spacing: 9) {
                    Text("Свой период")
                        .font(.system(size: 11, weight: .bold))
                        .textCase(.uppercase)
                        .tracking(0.4)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        dateField(label: "С", date: $customFrom)
                        dateField(label: "По", date: $customTo)
                    }
                }
                .padding(.top, 16)

                HStack(spacing: 8) {
                    Button(action: onReset) {
                        Text("Сбросить")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("Card"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color("Line"))
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: onApply) {
                        Text("Показать \(shownCount)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color("AccentLabel"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.brandAccent)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private func presetButton(_ option: OrderDatePreset) -> some View {
        let isActive = preset == option
        return Button {
            preset = option
        } label: {
            HStack(spacing: 6) {
                Text(option.label)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Spacer(minLength: 4)

                if option != .custom {
                    Text("\(counts(option))")
                        .font(.system(size: 11, weight: .bold))
                        .opacity(0.6)
                }
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 12)
            .foregroundStyle(isActive ? Color("AccentInk") : Color.primary.opacity(0.85))
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(isActive ? Color("AccentBg") : Color("Card"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(isActive ? Color.brandAccent : Color("Line"))
            )
        }
        .buttonStyle(.plain)
    }

    private func dateField(label: String, date: Binding<Date?>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.tertiary)

            DatePicker(
                "",
                selection: Binding(
                    get: { date.wrappedValue ?? .now },
                    set: { newValue in
                        date.wrappedValue = newValue
                        preset = .custom
                    }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color("Card"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color("Line"))
            )
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OrderDateFilterSheetView(
        preset: .constant(.today),
        customFrom: .constant(nil),
        customTo: .constant(nil),
        counts: { _ in 3 },
        shownCount: 3
    )
    .appBackground()
}
