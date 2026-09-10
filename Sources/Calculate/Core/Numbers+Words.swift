//
//  Numbers+Words.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//
//  Numbers written the way a person reads them aloud.
//

import Foundation

extension Numbers {

    /// `1st`, `22nd`, `13th`, `111th`, `-1st` — English ordinals.
    ///
    /// The rule people get wrong is the teens: 11th, 12th and 13th, and so
    /// 111th and 112th, whatever the last digit says. English only; other
    /// languages inflect ordinals by gender and case, and a table for one
    /// language pretending to be general would be worse than none.
    public static func ordinal(_ n: Int) -> String {
        Ordinals.ordinal(n)
    }

    /// A whole number in words: `123` → "one hundred and twenty-three".
    ///
    /// Covers the whole of `Int`, up to nine quintillion, with British
    /// spelling by default — "and" after the hundreds, commas between the
    /// thousands groups — and American on request. Negative numbers say
    /// "minus". Hand-written rather than `NumberFormatter`'s `.spellOut`,
    /// which cannot be told whether to say "and".
    public static func spelledOut(_ n: Int, style: SpellingStyle = .british) -> String {
        NumberWords.words(for: n, style: style)
    }

    /// A decimal in words: `12.5` → "twelve point five", digits spoken one
    /// at a time after the point, the way a person reads a decimal.
    ///
    /// Rounded to `fractionDigits` first, with trailing zeros dropped, so
    /// `12.50` is still "twelve point five" and `3.0` is "three". Non-finite
    /// values are written as they are: "not a number", "infinity".
    public static func spelledOut(_ value: Double, fractionDigits: Int = 2, style: SpellingStyle = .british) -> String {
        NumberWords.words(for: value, fractionDigits: fractionDigits, style: style)
    }
}
