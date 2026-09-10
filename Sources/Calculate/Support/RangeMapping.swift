//
//  RangeMapping.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Clamping and linear mapping between two pairs of bounds.
enum RangeMapping {

    /// `value` held between `lower` and `upper`.
    static func clamp(_ value: Double, lower: Double, upper: Double) -> Double {
        Swift.min(Swift.max(value, lower), upper)
    }

    /// The linear map of `value` from `source` onto `target`. Either pair
    /// may run backwards; the source may not be a single point.
    static func map(_ value: Double, from source: (Double, Double), to target: (Double, Double)) throws -> Double {
        let width = source.1 - source.0
        guard width != 0 else { throw CalculateError.emptyRange }
        let fraction = (value - source.0) / width
        return target.0 + fraction * (target.1 - target.0)
    }
}
