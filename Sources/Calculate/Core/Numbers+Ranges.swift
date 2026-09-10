//
//  Numbers+Ranges.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  Parity, and keeping or mapping a value between two bounds.
//

import Foundation

extension Numbers {

    /// Whether `n` is even. Zero is even; `-4` is even.
    public static func isEven(_ n: Int) -> Bool { n.isMultiple(of: 2) }

    /// Whether `n` is odd. `-3` is odd.
    public static func isOdd(_ n: Int) -> Bool { !n.isMultiple(of: 2) }

    /// `value`, pulled back inside `range` if it lies outside.
    public static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        RangeMapping.clamp(value, lower: range.lowerBound, upper: range.upperBound)
    }

    /// The integer form of ``clamp(_:to:)``.
    public static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(value, range.lowerBound), range.upperBound)
    }

    /// Maps `value` from one range onto another, linearly: `50` from
    /// `0…100` onto `0…1` is `0.5`.
    ///
    /// The bounds are pairs rather than ranges so a target can run backwards
    /// — `0…1` onto `(100, 0)` turns a fraction into a countdown — which a
    /// `ClosedRange` cannot express. Values outside the source extrapolate;
    /// ``clamp(_:to:)`` first if that is not wanted.
    ///
    /// - Throws: ``CalculateError/emptyRange`` when the source's two bounds
    ///   are equal, because every value would map to the same point and
    ///   division by zero would say infinity instead.
    public static func map(_ value: Double, from source: (Double, Double), to target: (Double, Double)) throws -> Double {
        try RangeMapping.map(value, from: source, to: target)
    }

    /// ``map(_:from:to:)`` for two forward ranges.
    public static func map(_ value: Double, from source: ClosedRange<Double>, to target: ClosedRange<Double>) throws -> Double {
        try RangeMapping.map(
            value,
            from: (source.lowerBound, source.upperBound),
            to: (target.lowerBound, target.upperBound)
        )
    }
}
