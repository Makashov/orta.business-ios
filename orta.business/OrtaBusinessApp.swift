import SwiftUI

@main struct OrtaBusinessApp: App {
    @State private var authViewModel = AuthViewModel()

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
        }
    }
}
