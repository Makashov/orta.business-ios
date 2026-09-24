//
//  PulseConsoleModifier.swift
//  orta.business
//
//  Created by Nurbol Makashov on 19.09.2026.
//

#if DEBUG && os(iOS)
import SwiftUI
import PulseUI

private struct PulseConsoleModifier: ViewModifier {
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onShake { isPresented = true }
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    ConsoleView()
                }
            }
    }
}

extension View {
    /// Shake the device to open the Pulse network/log console. Debug builds only.
    func pulseConsoleOnShake() -> some View {
        modifier(PulseConsoleModifier())
    }
}
#endif
