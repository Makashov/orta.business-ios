import SwiftUI

@main struct OrtaBusinessApp: App {
    @State private var authViewModel = AuthViewModel()
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
            .preferredColorScheme(isDarkModeOn ? .dark : .light)
            #if DEBUG
            .pulseConsoleOnShake()
            #endif
        }
    }
}
