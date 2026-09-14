//
//  BaseConversion.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Reading and writing whole numbers in other bases.
enum BaseConversion {

    /// Bases a digit string can meaningfully use.
    static let supported = 2...36

    /// The base a written number declares, by its prefix.
    ///
    /// Returns the radix and the digits with the prefix removed, so a caller
    /// never has to strip it twice.
    static func detect(_ text: String) -> (radix: Int, digits: String, negative: Bool) {
        var body = text.trimmingCharacters(in: .whitespaces)
        // Separators are for reading: 1_000_000 and DE AD BE EF are both
        // written by people who mean one number.
        body = body.replacingOccurrences(of: "_", with: "")
        body = body.replacingOccurrences(of: " ", with: "")

        var negative = false
        if body.hasPrefix("-") { negative = true; body.removeFirst() }
        else if body.hasPrefix("+") { body.removeFirst() }

        let lowered = body.lowercased()
        for base in [NumberBase.hexadecimal, .binary, .octal] where lowered.hasPrefix(base.prefix) {
            return (base.rawValue, String(body.dropFirst(base.prefix.count)), negative)
        }
        // `#FF0000` is how a colour is written, and it is hexadecimal.
        if body.hasPrefix("#") { return (16, String(body.dropFirst()), negative) }
        return (10, body, negative)
    }

    /// Whether every character is a digit of the given base.
    static func isValid(_ digits: String, radix: Int) -> Bool {
        guard !digits.isEmpty else { return false }
        return digits.allSatisfy { character in
            guard let value = character.hexDigitValue ?? alphabetValue(character) else { return false }
            return value < radix
        }
    }

    /// Letter values past `f`, which `hexDigitValue` stops at.
    private static func alphabetValue(_ character: Character) -> Int? {
        guard let ascii = character.lowercased().first?.asciiValue,
              ascii >= 97, ascii <= 122 else { return nil }
        return Int(ascii - 97) + 10
    }

    /// Writes a value in a base, without a prefix.
    static func format(_ value: Int64, radix: Int, uppercase: Bool) -> String {
        let magnitude = String(value.magnitude, radix: radix, uppercase: uppercase)
        return value < 0 ? "-" + magnitude : magnitude
    }

    /// Groups digits for reading: bytes for binary, fours for hex.
    ///
    /// A 32-bit binary number is unreadable as one run, and the grouping people
    /// actually use differs by base.
    static func grouped(_ digits: String, radix: Int) -> String {
        let size: Int
        switch radix {
        case 2: size = 4
        case 16: size = 4
        case 8: size = 3
        default: size = 3
        }
        var negative = false
        var body = digits
        if body.hasPrefix("-") { negative = true; body.removeFirst() }
        guard body.count > size else { return digits }

        var out: [String] = []
        var remaining = Substring(body)
        while remaining.count > size {
            out.append(String(remaining.suffix(size)))
            remaining = remaining.dropLast(size)
        }
        out.append(String(remaining))
        let joined = out.reversed().joined(separator: " ")
        return negative ? "-" + joined : joined
    }
}
