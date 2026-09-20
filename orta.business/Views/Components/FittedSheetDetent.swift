//
//  FittedSheetDetent.swift
//  orta.business
//
//  Created by Nurbol Makashov on 20.09.2026.
//

import SwiftUI

private struct FittedSheetDetent: ViewModifier {
    @State private var height: CGFloat = 460

    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height = $0 }
            .frame(maxHeight: .infinity, alignment: .top)
            .presentationDetents([.height(height), .large])
    }
}

extension View {
    /// Sizes a sheet to its content's height (still expandable to full height).
    /// Apply to the sheet's root content.
    func fittedSheetDetent() -> some View {
        modifier(FittedSheetDetent())
    }
}
