//
//  View+AppBackground.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

extension View {
    /// Fills the whole screen (including safe areas) with the shared app background.
    func appBackground() -> some View {
        background(Color("Bg").ignoresSafeArea())
    }
}
