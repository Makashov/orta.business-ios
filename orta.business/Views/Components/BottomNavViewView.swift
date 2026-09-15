import SwiftUI

struct BottomNavViewView: View {
    var body: some View {
        VStack(spacing: 0) {
            MainHeaderView()
            
            TabView {
                NavigationStack {
                    OrdersListView()
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
                NavigationStack {
                    OrdersListView()
                }
                .tabItem {
                    Label("Orders", systemImage: "list.clipboard")
                }
                
                NavigationStack {
                    OrderCreateView()
                }
                .tabItem {
                    Label("Create", systemImage: "plus.app.fill")
                }
                
                NavigationStack {
                    OrdersListView()
                }
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
                
                NavigationStack {
                    OrdersListView()
                }
                .tabItem {
                    Label("Menu", systemImage: "list.bullet")
                }
            }
        }
    }
}

#Preview {
    BottomNavViewView()
}
