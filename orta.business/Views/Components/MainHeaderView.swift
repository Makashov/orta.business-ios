//
//  MainHeader.swift
//  orta.business
//
//  Created by Nurbol Makashov on 15.09.2026.
//

import SwiftUI

struct MainHeaderView: View {
    var body: some View {
        HStack {
            Text("My App")
                .font(.headline)
            Spacer()
            // add buttons/icons here if needed
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

extension View {
    func mainHeader() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .top, spacing: 0) {
                MainHeaderView()
            }
    }
}

#Preview {
    MainHeaderView()
}
