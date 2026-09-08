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

//

import Foundation

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
            // "0x10" is sixteen. Without this it was zero: the x was read as
            // a multiply and the answer came back silently wrong, which is the
            // one thing this library exists to never do.
            if character == "0", index + 2 < characters.count,
               "xX".contains(characters[index + 1]), characters[index + 2].isHexDigit {
                var hex = ""
                index += 2
                while index < characters.count, characters[index].isHexDigit {
                    hex.append(characters[index])
                    index += 1
                }
                guard let value = UInt64(hex, radix: 16) else {
                    throw CalculateError.unexpectedToken("0x" + hex, at: start)
                }
                tokens.append(.init(token: .number(Double(value)), index: start))
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
                // "1 000 000": a space then exactly three digits is a thousands
                // separator — the French and Swiss convention, and how plenty
                // of people type a big number anywhere. Exactly three, and no
                // fourth digit after, so "1 2" stays two numbers and an error.
                while !literal.contains("."),
                      index + 3 < characters.count + 0, characters[index] == " ",
                      characters[index + 1].isNumber, characters[index + 2].isNumber, characters[index + 3].isNumber,
                      !(index + 4 < characters.count && characters[index + 4].isNumber) {
                    literal += String(characters[(index + 1)...(index + 3)])
                    index += 4
                }
                if index < characters.count, characters[index] == ".", literal.allSatisfy(\.isNumber),
                   index + 1 < characters.count, characters[index + 1].isNumber {
                    // The decimal part after spaced thousands: "12 345.5".
                    literal.append(".")
                    index += 1
                    while index < characters.count, characters[index].isNumber {
                        literal.append(characters[index])
                        index += 1
                    }
                }
                guard let value = Double(literal) else {
                    throw CalculateError.unexpectedToken(literal, at: start)
                }
                tokens.append(.init(token: .number(value), index: start))
                continue
            }
            // The word, for people who write it: "7 mod 3".
            if index + 2 < characters.count,
               String(characters[index...(index + 2)]).lowercased() == "mod",
               !(index + 3 < characters.count && characters[index + 3].isLetter) {
                tokens.append(.init(token: .symbol(.modulo), index: start))
                index += 3
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
