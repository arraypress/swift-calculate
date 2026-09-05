//
//  Lexer.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  Turning text into tokens, and refusing anything else.
//
//  Kept apart from the parser so a malformed expression can be shown to fail
//  at the right character, and so the token stream is assertable on its own.
//

import Foundation

/// One piece of an expression.
enum Token: Equatable {
    case number(Double)
    case symbol(Operator)
    case openParen
    case closeParen

    /// Where it started, for error messages.
    struct Placed: Equatable {
        let token: Token
        let index: Int
    }
}

/// The operators understood, and how they bind.
enum Operator: String, CaseIterable, Equatable, Sendable {
    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = "/"
    case modulo = "%"
    case power = "^"

    /// Higher binds tighter.
    var precedence: Int {
        switch self {
        case .add, .subtract: return 1
        case .multiply, .divide, .modulo: return 2
        case .power: return 3
        }
    }

    /// Power is right-associative: `2^3^2` is 2^(3^2), not (2^3)^2.
    var isRightAssociative: Bool { self == .power }
}

/// Reads an expression into tokens.
enum Lexer {

    /// The multiplication signs people actually type.
    private static let timesCharacters: Set<Character> = ["×", "x", "X", "*"]
    /// The division signs people actually type.
    private static let divideCharacters: Set<Character> = ["÷", "/"]

    /// Tokenises, or throws naming the offending character and its position.
    static func tokenise(_ input: String) throws -> [Token.Placed] {
        var tokens: [Token.Placed] = []
        let characters = Array(input)
        var index = 0

        while index < characters.count {
            let character = characters[index]
            let start = index

            if character.isWhitespace {
                index += 1
                continue
            }
            // Thousands separators are noise, not structure: 1,000 is 1000.
            // Only between digits, so a stray comma is still an error.
            if character == "," ,
               index > 0, characters[index - 1].isNumber,
               index + 1 < characters.count, characters[index + 1].isNumber {
                index += 1
                continue
            }
            if character.isNumber || character == "." {
                var literal = ""
                while index < characters.count,
                      characters[index].isNumber || characters[index] == "."
                        || (characters[index] == "," && index + 1 < characters.count && characters[index + 1].isNumber) {
                    if characters[index] != "," { literal.append(characters[index]) }
                    index += 1
                }
                guard let value = Double(literal) else {
                    throw CalculateError.unexpectedToken(literal, at: start)
                }
                tokens.append(.init(token: .number(value), index: start))
                continue
            }
            if character == "(" || character == "[" {
                tokens.append(.init(token: .openParen, index: start))
                index += 1
                continue
            }
            if character == ")" || character == "]" {
                tokens.append(.init(token: .closeParen, index: start))
                index += 1
                continue
            }
            if timesCharacters.contains(character) {
                tokens.append(.init(token: .symbol(.multiply), index: start))
                index += 1
                continue
            }
            if divideCharacters.contains(character) {
                tokens.append(.init(token: .symbol(.divide), index: start))
                index += 1
                continue
            }
            // A minus sign as typed by a word processor.
            if character == "−" {
                tokens.append(.init(token: .symbol(.subtract), index: start))
                index += 1
                continue
            }
            if let symbol = Operator(rawValue: String(character)) {
                tokens.append(.init(token: .symbol(symbol), index: start))
                index += 1
                continue
            }
            throw CalculateError.unexpectedCharacter(character, at: start)
        }
        return tokens
    }
}
