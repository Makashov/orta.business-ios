//
//  CardSurface.swift
//  orta.business
//
//  Created by Nurbol Makashov on 16.09.2026.
//

import SwiftUI

/// A flat, opaque card fill used instead of `.regularMaterial`.
/// Materials are a live backdrop blur that gets re-sampled every frame while
/// scrolling; stacking several of them (stats card + tiles + order rows) is
/// expensive and causes scroll stutter, especially in the Simulator. A plain
/// solid fill matches the source design (which has no blur) and is effectively free.
private struct CardSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(colorScheme == .dark ? Color(red: 0.086, green: 0.118, blue: 0.153) : .white)
        )
    }
}

extension View {
    func cardSurface(cornerRadius: CGFloat) -> some View {
        modifier(CardSurfaceModifier(cornerRadius: cornerRadius))
    }
}
