import SwiftUI

private enum AppTab: Hashable {
    case home, orders, create, statistics, menu
}

private struct CreateRoute: Hashable {}

struct BottomNavViewView: View {
    @State private var selectedTab: AppTab = .home
    @State private var previousTab: AppTab = .home

    @State private var homePath = NavigationPath()
    @State private var ordersPath = NavigationPath()
    @State private var statisticsPath = NavigationPath()
    @State private var menuPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView()
                    .navigationDestination(for: CreateRoute.self) { _ in
                        OrderCreateView()
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.home)

            NavigationStack(path: $ordersPath) {
                OrdersListView()
                    .navigationDestination(for: CreateRoute.self) { _ in
                        OrderCreateView()
                    }
            }
            .tabItem {
                Label("Orders", systemImage: "list.clipboard")
            }
            .tag(AppTab.orders)

            Color.clear
                .tabItem {
                    Label("Create", systemImage: "plus.app.fill")
                }
                .tag(AppTab.create)

            NavigationStack(path: $statisticsPath) {
                OrdersListView()
                    .navigationDestination(for: CreateRoute.self) { _ in
                        OrderCreateView()
                    }
            }
            .tabItem {
                Label("Statistics", systemImage: "chart.bar.xaxis")
            }
            .tag(AppTab.statistics)

            NavigationStack(path: $menuPath) {
                OrdersListView()
                    .navigationDestination(for: CreateRoute.self) { _ in
                        OrderCreateView()
                    }
            }
            .tabItem {
                Label("Menu", systemImage: "list.bullet")
            }
            .tag(AppTab.menu)
        }
        .onChange(of: selectedTab) { _, newValue in
            guard newValue == .create else {
                previousTab = newValue
                return
            }
            selectedTab = previousTab
            switch previousTab {
            case .home: homePath.append(CreateRoute())
            case .orders: ordersPath.append(CreateRoute())
            case .statistics: statisticsPath.append(CreateRoute())
            case .menu: menuPath.append(CreateRoute())
            case .create: break
            }
        }
    }
}

#Preview("Light Mode") {
    BottomNavViewView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    BottomNavViewView()
        .preferredColorScheme(.dark)
}
