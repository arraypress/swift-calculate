//
//  Operator.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The operators understood, and how they bind.
enum Operator: String, CaseIterable, Equatable, Sendable {
    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = "/"
    case modulo = "%"
    case power = "^"

    /// Higher binds tighter.
    var precedence: Int {
        switch self {
        case .add, .subtract: return 1
        case .multiply, .divide, .modulo: return 2
        case .power: return 3
        }
    }

    /// Power is right-associative: `2^3^2` is 2^(3^2), not (2^3)^2.
    var isRightAssociative: Bool { self == .power }
}
