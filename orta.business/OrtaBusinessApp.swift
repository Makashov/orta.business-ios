import SwiftUI

@main struct OrtaBusinessApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var orderStatusStore = OrderStatusStore()
    @AppStorage("isDarkModeOn") private var isDarkModeOn = false

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.session != nil {
                    BottomNavViewView()
                } else {
                    LoginView()
                }
            }
            .environment(authViewModel)
            .environment(orderStatusStore)
            .preferredColorScheme(isDarkModeOn ? .dark : .light)
            #if DEBUG
            .pulseConsoleOnShake()
            #endif
        }
    }
}
