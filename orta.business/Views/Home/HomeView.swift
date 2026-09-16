//
//  HomeView.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TodayStatsCardView()
                QuickActionsGridView()
                RecentOrdersSectionView()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 108)
        }
        .mainHeader()
    }
}

#Preview("Light Mode") {
    HomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    HomeView()
        .preferredColorScheme(.dark)
}
