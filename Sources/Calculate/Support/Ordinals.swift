//
//  Ordinals.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The English ordinal suffix rule.
enum Ordinals {

    /// `st`, `nd`, `rd` or `th` for a whole number, teens included.
    static func suffix(for n: Int) -> String {
        let lastTwo = abs(n) % 100
        if (11...13).contains(lastTwo) { return "th" }
        switch abs(n) % 10 {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }

    /// The number with its suffix.
    static func ordinal(_ n: Int) -> String {
        "\(n)\(suffix(for: n))"
    }
}
