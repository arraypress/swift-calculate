//
//  Numbers.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  The other half: numbers pulled out of ordinary prose, and reduced.
//
//  Distinct from a stats tool over a column of data — the input here is a
//  sentence ("spent 12.50, 8 and 30.25 on lunch"), not a file. That is the
//  question a keyboard or an agent actually gets asked.
//

import Foundation

/// Finding and reducing the numbers in a piece of text.
public enum Numbers {

    /// Every number in `text`, in the order they appear.
    ///
    /// Understands decimals, thousands separators and negative signs, and
    /// ignores digits embedded in words so `abc123` is not a number but
    /// `-1,234.5` is.
    public static func all(in text: String) -> [Double] {
        var found: [Double] = []
        let characters = Array(text)
        var index = 0

        while index < characters.count {
            guard characters[index].isNumber
                    || (characters[index] == "-" && index + 1 < characters.count && characters[index + 1].isNumber)
                    || (characters[index] == "." && index + 1 < characters.count && characters[index + 1].isNumber)
            else { index += 1; continue }

            // A digit run glued to letters is an identifier, not a number.
            if index > 0, characters[index - 1].isLetter {
                while index < characters.count, characters[index].isNumber || characters[index].isLetter {
                    index += 1
                }
                continue
            }
            let start = index
            if characters[index] == "-" { index += 1 }
            var literal = characters[index] == "-" ? "-" : String(characters[start])
            if start != index { literal = "-" } else { index += 1 }

            var seenDot = literal.contains(".")
            while index < characters.count {
                let character = characters[index]
                if character.isNumber {
                    literal.append(character)
                    index += 1
                } else if character == ".", !seenDot,
                          index + 1 < characters.count, characters[index + 1].isNumber {
                    seenDot = true
                    literal.append(character)
                    index += 1
                } else if character == ",",
                          index + 1 < characters.count, characters[index + 1].isNumber {
                    index += 1   // a thousands separator, dropped
                } else {
                    break
                }
            }
            // A trailing letter means it was an identifier after all: 123abc.
            if index < characters.count, characters[index].isLetter {
                while index < characters.count, characters[index].isNumber || characters[index].isLetter {
                    index += 1
                }
                continue
            }
            if let value = Double(literal) { found.append(value) }
        }
        return found
    }

    /// Sum of the numbers in `text`, or `nil` when there are none.
    public static func sum(in text: String) -> Double? {
        let values = all(in: text)
        return values.isEmpty ? nil : values.reduce(0, +)
    }

    /// Arithmetic mean.
    public static func mean(in text: String) -> Double? {
        let values = all(in: text)
        return values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
    }

    /// Median — the middle value, or the mean of the middle two.
    public static func median(in text: String) -> Double? {
        let values = all(in: text).sorted()
        guard !values.isEmpty else { return nil }
        let middle = values.count / 2
        return values.count.isMultiple(of: 2)
            ? (values[middle - 1] + values[middle]) / 2
            : values[middle]
    }

    /// Smallest value.
    public static func minimum(in text: String) -> Double? { all(in: text).min() }

    /// Largest value.
    public static func maximum(in text: String) -> Double? { all(in: text).max() }

    /// How many numbers are in the text.
    public static func count(in text: String) -> Int { all(in: text).count }
}
