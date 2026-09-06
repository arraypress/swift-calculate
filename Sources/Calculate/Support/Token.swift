//
//  Token.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
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
