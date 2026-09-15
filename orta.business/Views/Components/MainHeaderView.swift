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

#Preview {
    MainHeaderView()
}
