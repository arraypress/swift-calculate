//
//  CalculateError.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// What can go wrong evaluating an expression.
///
/// Every failure is one of these. Nothing here traps, and nothing raises an
/// Objective-C exception — see ``Calculate`` for why that matters.
public enum CalculateError: Error, LocalizedError, Sendable, Equatable {
    /// A character that cannot appear in an expression.
    case unexpectedCharacter(Character, at: Int)
    /// The expression ended mid-way — `1 +`.
    case unexpectedEnd
    /// A token that cannot appear where it did — `2 * * 3`.
    case unexpectedToken(String, at: Int)
    /// A `(` with no `)`, or the reverse.
    case unbalancedParentheses
    /// Division, or a modulo, by zero.
    case divisionByZero
    /// The expression was empty or only whitespace.
    case empty
    /// The result is not a finite number — an overflow, or `0^-1`.
    case notFinite
    /// Nesting deeper than the parser will follow.
    case tooDeep

    /// A one-line reason, for a CLI or a log.
    public var errorDescription: String? {
        switch self {
        case .unexpectedCharacter(let character, let index):
            return "unexpected '\(character)' at position \(index + 1)"
        case .unexpectedEnd:
            return "the expression ends unexpectedly"
        case .unexpectedToken(let token, let index):
            return "unexpected '\(token)' at position \(index + 1)"
        case .unbalancedParentheses:
            return "unbalanced parentheses"
        case .divisionByZero:
            return "division by zero"
        case .empty:
            return "nothing to calculate"
        case .notFinite:
            return "the result is not a finite number"
        case .tooDeep:
            return "the expression nests too deeply"
        }
    }
}
