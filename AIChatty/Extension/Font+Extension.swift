//
//  Font+Extension.swift
//  AIChatty
//

import SwiftUI

let manropePath = Bundle.main.path(forResource: "Manrpoe", ofType: "ttf")

extension Font {
    static func manrope(size: CGFloat, weight: Font.Weight) -> Font {
        #if os(iOS)
        return Font.custom("Manrope", size: size).weight(weight)
        #else
        return .system(size: size - 2, weight: weight)
        #endif
    }
}
