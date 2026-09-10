//
//  StepRounding.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Rounding to a multiple of a step, in decimal.
enum StepRounding {

    /// `value` rounded to a multiple of `step` under `mode`.
    ///
    /// Both numbers go into `Decimal` through their short text form rather
    /// than the `Double` initialiser, which would carry the binary noise in —
    /// `Decimal(0.1)` is `0.1000000000000000055…` — and the result comes back
    /// out the same way, so the `Double` returned is the one that prints as
    /// `1.1`.
    static func round(_ value: Double, toNearest step: Double, mode: NSDecimalNumber.RoundingMode) throws -> Double {
        guard step > 0, step.isFinite else { throw CalculateError.badStep(step) }
        guard value.isFinite else { return value }
        guard let decimalValue = Decimal(string: Formatting.plain(value)),
              let decimalStep = Decimal(string: Formatting.plain(step)) else {
            return value
        }
        var quotient = decimalValue / decimalStep
        var rounded = Decimal()
        NSDecimalRound(&rounded, &quotient, 0, mode)
        let result = rounded * decimalStep
        // A rounded zero can carry a minus sign; nobody wants "-0".
        if result == 0 { return 0 }
        return Double("\(result)") ?? value
    }
}
