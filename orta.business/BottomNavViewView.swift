import SwiftUI

struct BottomNavViewView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Search", systemImage: "list.clipboard")
            }

            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Favorites", systemImage: "plus.app.fill")
            }

            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Alerts", systemImage: "chart.bar.xaxis")
            }

            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Profile", systemImage: "list.bullet")
            }
        }
    }
}

#Preview {
    BottomNavViewView()
}
