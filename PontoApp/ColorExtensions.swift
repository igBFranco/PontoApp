//
//  ColorExtensions.swift
//  PontoApp
//
//  Created by Igor Bueno Franco on 14/10/24.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String, defaultColor: Color = .clear) {
        let r, g, b: Double
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        if Scanner(string: hexSanitized).scanHexInt64(&rgb) {
            switch hexSanitized.count {
            case 6:
                r = Double((rgb >> 16) & 0xFF) / 255.0
                g = Double((rgb >> 8) & 0xFF) / 255.0
                b = Double(rgb & 0xFF) / 255.0
                self.init(red: r, green: g, blue: b)
            default:
                self = defaultColor
                return
            }
        } else {
            self = defaultColor 
            return
        }
    }
}
