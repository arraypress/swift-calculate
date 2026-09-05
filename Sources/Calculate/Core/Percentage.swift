//
//  Percentage.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  The four percentage questions people actually ask, named so the caller
//  cannot get them the wrong way round — which is the usual bug.
//

import Foundation

/// Percentage arithmetic.
public enum Percentage {

    /// `15% of 200` → 30.
    public static func of(_ percent: Double, _ total: Double) -> Double {
        total * percent / 100
    }

    /// `30 is what percent of 200` → 15.
    ///
    /// Returns `nil` for a total of zero rather than an infinity.
    public static func what(_ part: Double, of total: Double) -> Double? {
        guard total != 0 else { return nil }
        return part / total * 100
    }

    /// The change from `from` to `to`, as a percentage. Negative is a fall.
    ///
    /// Returns `nil` when the starting value is zero: every increase from
    /// nothing is infinite, and reporting a number there would be a lie.
    public static func change(from: Double, to: Double) -> Double? {
        guard from != 0 else { return nil }
        return (to - from) / abs(from) * 100
    }

    /// `200 plus 15%` → 230. A negative percent discounts.
    public static func adding(_ percent: Double, to total: Double) -> Double {
        total + of(percent, total)
    }
}
