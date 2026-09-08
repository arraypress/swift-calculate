//
//  PercentageParsing.swift
//  Calculate
//
//  The percentage questions, as people write them.
//

import Foundation

public extension Percentage {

    /// What a percentage phrase works out to, or nil when it is not one.
    ///
    /// | Written | Answers |
    /// |---|---|
    /// | `15% of 200` | 30 |
    /// | `30 is what percent of 200` | 15 |
    /// | `200 + 15%`, `200 plus 15%` | 230 |
    /// | `200 - 15%`, `200 less 15%` | 170 |
    /// | `from 80 to 100` | 25, the change |
    ///
    /// Separate from ``Calculate/evaluate(_:)`` because `%` there is modulo, as
    /// it is in every programming language, and "15 % of 200" is not an
    /// arithmetic expression at all — it is English.
    ///
    /// Returns nil rather than throwing: this is asked speculatively, of text
    /// that is usually not a percentage question.
    static func evaluate(_ raw: String) -> Double? {
        let text = raw
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "percent", with: "%")
            .replacingOccurrences(of: "  ", with: " ")
        guard text.contains("%") || text.hasPrefix("from ") else { return nil }

        // Ordered: "what % of" has to be tried before the plainer "% of", or
        // the shorter pattern matches the tail of the longer question.
        if let answer = whatPercentOf(text) { return answer }
        if let answer = addedOrRemoved(text) { return answer }
        if let answer = percentOf(text) { return answer }
        return changeFromTo(text)
    }

    // MARK: - The four shapes

    /// `30 is what % of 200`, and the same without "is".
    private static func whatPercentOf(_ text: String) -> Double? {
        guard let (part, total) = numbers(text, pattern: #"^(-?[\d.,]+)\s*(?:is)?\s*what\s*%\s*of\s*(-?[\d.,]+)$"#)
        else { return nil }
        return what(part, of: total)
    }

    /// `15% of 200`.
    private static func percentOf(_ text: String) -> Double? {
        guard let (percent, total) = numbers(text, pattern: #"^(-?[\d.,]+)\s*%\s*of\s*(-?[\d.,]+)$"#)
        else { return nil }
        return of(percent, total)
    }

    /// `200 + 15%`, `200 plus 15%`, and their subtracting counterparts.
    ///
    /// A discount is the same operation with the sign flipped, which is why
    /// ``adding(_:to:)`` takes a negative rather than there being two of it.
    private static func addedOrRemoved(_ text: String) -> Double? {
        let pattern = #"^(-?[\d.,]+)\s*(\+|plus|added to|-|−|minus|less|off)\s*(-?[\d.,]+)\s*%$"#
        guard let match = firstMatch(text, pattern: pattern), match.numberOfRanges == 4 else { return nil }
        let ns = text as NSString
        guard let total = number(ns.substring(with: match.range(at: 1))),
              let percent = number(ns.substring(with: match.range(at: 3)))
        else { return nil }

        let word = ns.substring(with: match.range(at: 2))
        let subtracting = ["-", "−", "minus", "less", "off"].contains(word)
        return adding(subtracting ? -percent : percent, to: total)
    }

    /// `from 80 to 100` — the change, which is the question behind every
    /// "is that up or down, and by how much".
    private static func changeFromTo(_ text: String) -> Double? {
        guard let (start, end) = numbers(text, pattern: #"^from\s*(-?[\d.,]+)\s*to\s*(-?[\d.,]+)\s*%?$"#)
        else { return nil }
        return change(from: start, to: end)
    }

    // MARK: - Reading the numbers

    private static func firstMatch(_ text: String, pattern: String) -> NSTextCheckingResult? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let ns = text as NSString
        return regex.firstMatch(in: text, range: NSRange(location: 0, length: ns.length))
    }

    /// Both captured numbers, when a two-number pattern matches.
    private static func numbers(_ text: String, pattern: String) -> (Double, Double)? {
        guard let match = firstMatch(text, pattern: pattern), match.numberOfRanges == 3 else { return nil }
        let ns = text as NSString
        guard let first = number(ns.substring(with: match.range(at: 1))),
              let second = number(ns.substring(with: match.range(at: 2)))
        else { return nil }
        return (first, second)
    }

    /// Reads `1,000` and `1000` alike, and rejects `1,0,0`.
    private static func number(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: ""))
    }
}
