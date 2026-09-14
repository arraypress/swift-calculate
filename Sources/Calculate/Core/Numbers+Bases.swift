//
//  Numbers+Bases.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension Numbers {

    /// The value a written number has, whatever base it is written in.
    ///
    /// The base is taken from the prefix — `0x`, `0b`, `0o` or `#` — unless
    /// one is given. Underscores and spaces are ignored, because `1_000_000`
    /// and `DE AD BE EF` are both written by people who mean one number.
    static func value(of text: String, from radix: Int? = nil) throws -> Int64 {
        let detected = BaseConversion.detect(text)
        let base = radix ?? detected.radix

        guard BaseConversion.supported.contains(base) else {
            throw CalculateError.baseOutOfRange(base)
        }

        // An explicit base overrides the prefix, but a prefix that disagrees
        // with it is a mistake worth refusing rather than quietly ignoring:
        // reading "0xFF" as decimal would be nonsense either way.
        let digits = detected.digits
        guard BaseConversion.isValid(digits, radix: base) else {
            throw CalculateError.badDigit(text, base: base)
        }
        guard let magnitude = Int64(digits, radix: base) else {
            throw CalculateError.valueTooLarge(text)
        }
        return detected.negative ? -magnitude : magnitude
    }

    /// Rewrites a number in another base.
    ///
    /// ```swift
    /// try Numbers.rebase("0xFF", to: 2)              // "11111111"
    /// try Numbers.rebase("255", to: 16, uppercase: true, prefixed: true)  // "0xFF"
    /// ```
    static func rebase(
        _ text: String,
        to radix: Int,
        from source: Int? = nil,
        uppercase: Bool = true,
        prefixed: Bool = false,
        grouped: Bool = false
    ) throws -> String {
        guard BaseConversion.supported.contains(radix) else {
            throw CalculateError.baseOutOfRange(radix)
        }
        let value = try value(of: text, from: source)
        var out = BaseConversion.format(value, radix: radix, uppercase: uppercase)
        if grouped { out = BaseConversion.grouped(out, radix: radix) }
        if prefixed, let named = NumberBase(rawValue: radix), !named.prefix.isEmpty {
            out = out.hasPrefix("-")
                ? "-" + named.prefix + out.dropFirst()
                : named.prefix + out
        }
        return out
    }

    /// The same number in all four named bases, which is usually what someone
    /// wanted when they could not say which one they needed.
    static func allBases(
        _ text: String,
        from source: Int? = nil,
        uppercase: Bool = true,
        grouped: Bool = false
    ) throws -> [(base: NumberBase, digits: String)] {
        let value = try value(of: text, from: source)
        return NumberBase.allCases.map { base in
            var digits = BaseConversion.format(value, radix: base.rawValue, uppercase: uppercase)
            if grouped, base != .decimal { digits = BaseConversion.grouped(digits, radix: base.rawValue) }
            return (base, digits)
        }
    }
}
