//
//  NumberWords.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  Whole numbers and decimals in English words.
//

import Foundation

/// Spelling numbers out, one thousands-group at a time.
enum NumberWords {

    private static let ones = [
        "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
        "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
        "seventeen", "eighteen", "nineteen",
    ]

    private static let tens = [
        "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety",
    ]

    /// Names of the thousands groups, smallest first. Seven of them cover
    /// `Int.max`, which is nine quintillion and change.
    private static let groups = ["", "thousand", "million", "billion", "trillion", "quadrillion", "quintillion"]

    /// A whole number in words.
    static func words(for n: Int, style: SpellingStyle) -> String {
        if n == 0 { return ones[0] }
        // The magnitude is taken as UInt64 so Int.min, whose magnitude does
        // not fit in an Int, is not a trap.
        let magnitude = n.magnitude
        var chunks: [UInt] = []
        var remaining = magnitude
        while remaining > 0 {
            chunks.append(remaining % 1000)
            remaining /= 1000
        }
        // Largest group first, empty groups skipped, so 1,000,001 is
        // "one million and one" and not "one million, zero thousand and one".
        var parts: [(text: String, chunk: UInt)] = []
        for index in stride(from: chunks.count - 1, through: 0, by: -1) where chunks[index] > 0 {
            let group = groups[index]
            let text = hundreds(Int(chunks[index]), style: style) + (group.isEmpty ? "" : " " + group)
            parts.append((text, chunks[index]))
        }
        let joined = join(parts, style: style)
        return n < 0 ? "minus " + joined : joined
    }

    /// A decimal in words: the whole part, then each digit after the point.
    static func words(for value: Double, fractionDigits: Int, style: SpellingStyle) -> String {
        guard value.isFinite else {
            if value.isNaN { return "not a number" }
            return value < 0 ? "minus infinity" : "infinity"
        }
        let digits = max(0, fractionDigits)
        // Rounded in decimal, half away from zero — the same rule as
        // ``Numbers/round(_:toNearest:ties:)`` — rather than through `%f`,
        // which rounds an exact half to even and would say "two" for 2.5.
        // Decimal's text form carries no trailing zeros and no minus zero.
        var text: String
        if var decimal = Decimal(string: Formatting.plain(value)) {
            var rounded = Decimal()
            NSDecimalRound(&rounded, &decimal, digits, .plain)
            text = "\(rounded)"
        } else {
            text = Formatting.plain(value)
        }
        let negative = text.hasPrefix("-")
        if negative { text.removeFirst() }
        let pieces = text.split(separator: ".", maxSplits: 1).map(String.init)
        let whole = Int(pieces[0]) ?? 0
        var result = words(for: whole, style: style)
        if pieces.count == 2 {
            let spoken = pieces[1].map { ones[Int(String($0)) ?? 0] }.joined(separator: " ")
            result += " point " + spoken
        }
        // "-0.00" rounds to nothing: a negative sign on zero is noise.
        if negative, result != ones[0] { result = "minus " + result }
        return result
    }

    /// Joins the thousands groups: British with commas and an "and" before a
    /// final group under a hundred, American with spaces and no "and".
    private static func join(_ parts: [(text: String, chunk: UInt)], style: SpellingStyle) -> String {
        guard parts.count > 1 else { return parts.first?.text ?? "" }
        switch style {
        case .american:
            return parts.map(\.text).joined(separator: " ")
        case .british:
            let last = parts[parts.count - 1]
            let head = parts.dropLast().map(\.text).joined(separator: ", ")
            // "one thousand and one", "one million and twelve": the "and"
            // belongs to a final group with no hundreds of its own.
            return last.chunk < 100 ? head + " and " + last.text : head + ", " + last.text
        }
    }

    /// One group of up to three digits.
    private static func hundreds(_ n: Int, style: SpellingStyle) -> String {
        let hundred = n / 100
        let rest = n % 100
        var pieces: [String] = []
        if hundred > 0 { pieces.append(ones[hundred] + " hundred") }
        if rest > 0 {
            if hundred > 0, style == .british { pieces.append("and") }
            pieces.append(tensAndOnes(rest))
        }
        return pieces.joined(separator: " ")
    }

    /// Up to ninety-nine, hyphenated above twenty.
    private static func tensAndOnes(_ n: Int) -> String {
        if n < 20 { return ones[n] }
        let ten = tens[n / 10]
        let one = n % 10
        return one == 0 ? ten : ten + "-" + ones[one]
    }
}
