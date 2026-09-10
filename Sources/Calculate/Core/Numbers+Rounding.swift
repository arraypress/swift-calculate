//
//  Numbers+Rounding.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  Rounding to a step, done in decimal so 0.1 steps come out as 0.1.
//

import Foundation

extension Numbers {

    /// Rounds `value` to the nearest multiple of `step`: `12.3` to the nearest
    /// `0.5` is `12.5`; `1,234` to the nearest `100` is `1,200`.
    ///
    /// Computed in `Decimal`, not in binary floating point, because
    /// `round(1.06 / 0.1) * 0.1` in a `Double` is `1.1000000000000001` and the
    /// whole point of rounding was to get rid of that. Halfway values go away
    /// from zero by default (`2.5` → `3`, `-2.5` → `-3`, the schoolbook rule);
    /// pass `.toNearestOrEven` for banker's rounding, which sends them to the
    /// even neighbour (`2.5` → `2`, `3.5` → `4`).
    ///
    /// - Throws: ``CalculateError/badStep(_:)`` for a step that is zero,
    ///   negative or not finite — there is no "nearest multiple of nothing".
    public static func round(
        _ value: Double, toNearest step: Double, ties: FloatingPointRoundingRule = .toNearestOrAwayFromZero
    ) throws -> Double {
        try StepRounding.round(value, toNearest: step, mode: ties == .toNearestOrEven ? .bankers : .plain)
    }

    /// Rounds up to the next multiple of `step` — towards positive infinity,
    /// so `-1.2` to the nearest `0.5` up is `-1`, not `-1.5`.
    ///
    /// - Throws: ``CalculateError/badStep(_:)``.
    public static func roundUp(_ value: Double, toNearest step: Double) throws -> Double {
        try StepRounding.round(value, toNearest: step, mode: .up)
    }

    /// Rounds down to the previous multiple of `step` — towards negative
    /// infinity, so `-1.2` down is `-1.5`.
    ///
    /// - Throws: ``CalculateError/badStep(_:)``.
    public static func roundDown(_ value: Double, toNearest step: Double) throws -> Double {
        try StepRounding.round(value, toNearest: step, mode: .down)
    }
}
