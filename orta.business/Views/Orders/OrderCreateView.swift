//
//  OrderCreateView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 15.09.2026.
//

import SwiftUI

struct OrderCreateView: View {
    var body: some View {
        Text("Create Order View")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appBackground()
            .toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom) {
                OrderSummaryFooterView(total: 0)
            }
    }
}

#Preview {
    OrderCreateView()
}
