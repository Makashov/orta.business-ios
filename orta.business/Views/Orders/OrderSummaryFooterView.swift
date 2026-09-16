import SwiftUI

struct OrderSummaryFooterView: View {
    let total: Decimal
    var onSubmit: () -> Void = {}

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.title3.bold())
            }

            Button(action: onSubmit) {
                Text("Submit Order")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color("Bg"))
    }
}

#Preview {
    OrderSummaryFooterView(total: 42.5)
}
