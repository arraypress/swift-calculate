//
//  Formatting.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  Printing a result the way a person would write it.
//

import Foundation

/// Number formatting, kept pure.
enum Formatting {

    /// A number without trailing zeros — `4`, not `4.0`; `2.5`, not `2.500000`.
    ///
    /// Rounded to twelve significant places first, because binary floating
    /// point makes `0.1 + 0.2` into `0.30000000000000004`, and nobody typing
    /// that into a calculator wants to see it.
    static func plain(_ value: Double) -> String {
        guard value.isFinite else { return "not a number" }
        let rounded = significant(value, places: 12)
        if rounded == rounded.rounded(), abs(rounded) < 1e15 {
            return String(Int64(rounded))
        }
        // %g prints significant digits and drops trailing zeros itself, so
        // it agrees with the rounding above — %f would re-truncate to a fixed
        // number of DECIMAL places and disagree with it.
        return String(format: "%.12g", rounded)
    }

    /// Rounds to `places` significant figures.
    static func significant(_ value: Double, places: Int) -> Double {
        guard value != 0, value.isFinite else { return value }
        let magnitude = floor(log10(abs(value)))
        let factor = pow(10.0, Double(places) - magnitude - 1)
        guard factor.isFinite, factor != 0 else { return value }
        return (value * factor).rounded() / factor
    }
}
