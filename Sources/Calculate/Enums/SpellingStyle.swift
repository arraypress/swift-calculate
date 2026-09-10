//
//  SpellingStyle.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// How a number is written out in words on each side of the Atlantic.
///
/// The difference is one word. British English says "one hundred and
/// twenty-three" and "one thousand and one"; American drops the "and". Both
/// hyphenate twenty-one to ninety-nine.
public enum SpellingStyle: String, CaseIterable, Sendable, Codable {
    /// "one hundred and twenty-three", chunks joined with commas.
    case british
    /// "one hundred twenty-three", chunks joined with spaces.
    case american
}
