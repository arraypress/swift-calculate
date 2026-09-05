//
//  Calculate.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  Arithmetic that cannot take the process down with it.
//
//  The obvious way to evaluate a string in Foundation is
//  `NSExpression(format:)`. Do not. Measured 2026-09-05:
//
//    "1+"    raises an uncaught Objective-C NSException from
//            +[NSPredicate predicateWithFormat:] — Swift CANNOT catch it, and
//            the process dies. A half-typed expression is a crash.
//    "10/4"  answers 2. It does INTEGER division on integer operands, so the
//            wrong answer arrives silently.
//    "10/0"  answers 0 rather than failing.
//
//  A character allowlist does not help: all three of those inputs are digits
//  and operators. This library parses by hand instead. Every failure is a
//  thrown ``CalculateError``, every division is floating point, and nesting is
//  depth-capped so a pathological input cannot exhaust the stack.
//

import Foundation

/// Arithmetic over strings.
public enum Calculate {

    /// Evaluates an arithmetic expression.
    ///
    /// Understands `+ - * / % ^`, parentheses, unary minus, decimals and
    /// thousands separators, and the symbols people actually type — `×`, `÷`,
    /// `x` for multiply, `−` for minus, `[` for a bracket.
    ///
    /// ```swift
    /// try Calculate.evaluate("10 / 4")        // 2.5, not 2
    /// try Calculate.evaluate("(3 + 4) * 2")   // 14
    /// try Calculate.evaluate("2^3^2")         // 512 — right-associative
    /// try Calculate.evaluate("1,000 × 1.2")   // 1200
    /// ```
    ///
    /// - Throws: ``CalculateError``. Never traps, never raises.
    public static func evaluate(_ expression: String) throws -> Double {
        let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CalculateError.empty }
        return try Parser.evaluate(try Lexer.tokenise(trimmed))
    }

    /// Evaluates, and formats the result the way a person writes it.
    ///
    /// `4` rather than `4.0`, and `0.3` rather than `0.30000000000000004`.
    public static func evaluateToString(_ expression: String) throws -> String {
        Formatting.plain(try evaluate(expression))
    }

    /// Evaluates, or returns `nil` — for the many callers that only want to
    /// know whether a string happened to be arithmetic.
    public static func value(of expression: String) -> Double? {
        try? evaluate(expression)
    }
}

extension Calculate {

    /// Formats a number the way a person writes it — `4`, not `4.0`.
    ///
    /// Public so a caller rendering its own output agrees with
    /// ``evaluateToString(_:)`` rather than re-inventing the rounding.
    public static func formatted(_ value: Double) -> String {
        Formatting.plain(value)
    }
}
