//
//  NumberBase.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A base a whole number can be written in.
///
/// The four that have names and prefixes. Anything from 2 to 36 works through
/// `Numbers.rebase(_:to:)` — this enum is for the ones people ask for by word.
public enum NumberBase: Int, CaseIterable, Sendable, Codable {
    case binary = 2
    case octal = 8
    case decimal = 10
    case hexadecimal = 16

    /// The prefix that marks this base in source code.
    public var prefix: String {
        switch self {
        case .binary: "0b"
        case .octal: "0o"
        case .decimal: ""
        case .hexadecimal: "0x"
        }
    }

    public var name: String {
        switch self {
        case .binary: "binary"
        case .octal: "octal"
        case .decimal: "decimal"
        case .hexadecimal: "hexadecimal"
        }
    }

    /// Reads a base from a word, an abbreviation, or its number.
    public init?(name raw: String) {
        switch raw.trimmingCharacters(in: .whitespaces).lowercased() {
        case "binary", "bin", "b", "2": self = .binary
        case "octal", "oct", "o", "8": self = .octal
        case "decimal", "dec", "d", "10": self = .decimal
        case "hexadecimal", "hex", "h", "16": self = .hexadecimal
        default: return nil
        }
    }
}
