//
//  Parser.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  A recursive-descent parser over the token stream.
//
//  Written by hand rather than handed to `NSExpression(format:)`, because that
//  raises an Objective-C `NSException` on a half-typed expression — `1+` kills
//  the process, and Swift cannot catch it. It also does INTEGER division, so
//  `10/4` answers 2. Both measured 2026-09-05. Every failure here is a thrown
//  ``CalculateError``, and every division is floating point.
//
//  Grammar:
//
//      expression → term   (('+' | '-') term)*
//      term       → factor (('*' | '/' | '%') factor)*
//      factor     → unary  ('^' factor)?          — right-associative
//      unary      → ('-' | '+')* primary
//      primary    → number | '(' expression ')'
//

import Foundation

/// Evaluates a token stream.
struct Parser {

    /// How deep nesting may go before it is refused. Guards the stack: a
    /// pathological "((((((…" would otherwise recurse until the process dies,
    /// which is the failure this library exists to avoid.
    static let maximumDepth = 64

    private let tokens: [Token.Placed]
    private var position = 0
    private var depth = 0

    init(_ tokens: [Token.Placed]) {
        self.tokens = tokens
    }

    /// Parses and evaluates the whole stream.
    static func evaluate(_ tokens: [Token.Placed]) throws -> Double {
        guard !tokens.isEmpty else { throw CalculateError.empty }
        var parser = Parser(tokens)
        let value = try parser.expression()
        // Anything left over means the expression did not consume cleanly —
        // "5 5" parses a 5 and then finds another one.
        if let leftover = parser.peek() {
            throw CalculateError.unexpectedToken(leftover.token.description, at: leftover.index)
        }
        guard value.isFinite else { throw CalculateError.notFinite }
        return value
    }

    // MARK: - Grammar

    private mutating func expression() throws -> Double {
        var value = try term()
        while let symbol = peekOperator(), symbol == .add || symbol == .subtract {
            advance()
            let right = try term()
            value = symbol == .add ? value + right : value - right
        }
        return value
    }

    private mutating func term() throws -> Double {
        var value = try factor()
        while let symbol = peekOperator(), [.multiply, .divide, .modulo].contains(symbol) {
            advance()
            let right = try factor()
            switch symbol {
            case .multiply:
                value *= right
            case .divide:
                guard right != 0 else { throw CalculateError.divisionByZero }
                value /= right
            case .modulo:
                guard right != 0 else { throw CalculateError.divisionByZero }
                value = value.truncatingRemainder(dividingBy: right)
            default:
                break
            }
        }
        return value
    }

    private mutating func factor() throws -> Double {
        let base = try unary()
        guard peekOperator() == .power else { return base }
        advance()
        // Right-associative, so the exponent is parsed as another factor.
        let exponent = try factor()
        return pow(base, exponent)
    }

    private mutating func unary() throws -> Double {
        if let symbol = peekOperator(), symbol == .subtract || symbol == .add {
            advance()
            let value = try unary()
            return symbol == .subtract ? -value : value
        }
        return try primary()
    }

    private mutating func primary() throws -> Double {
        guard let placed = peek() else { throw CalculateError.unexpectedEnd }
        switch placed.token {
        case .number(let value):
            advance()
            return value
        case .openParen:
            advance()
            depth += 1
            guard depth <= Parser.maximumDepth else { throw CalculateError.tooDeep }
            defer { depth -= 1 }
            let value = try expression()
            guard let next = peek(), next.token == .closeParen else {
                throw CalculateError.unbalancedParentheses
            }
            advance()
            return value
        case .closeParen:
            throw CalculateError.unbalancedParentheses
        case .symbol(let symbol):
            throw CalculateError.unexpectedToken(symbol.rawValue, at: placed.index)
        }
    }

    // MARK: - Cursor

    private func peek() -> Token.Placed? {
        position < tokens.count ? tokens[position] : nil
    }

    private func peekOperator() -> Operator? {
        guard case .symbol(let symbol)? = peek()?.token else { return nil }
        return symbol
    }

    private mutating func advance() {
        position += 1
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        switch self {
        case .number(let value): return Formatting.plain(value)
        case .symbol(let symbol): return symbol.rawValue
        case .openParen: return "("
        case .closeParen: return ")"
        }
    }
}
