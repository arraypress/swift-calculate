//
//  CalculateTests.swift
//  CalculateTests
//
//  Created by David Sherlock on 2026.
//
//  The three tests that justify this library's existence are the ones named
//  after NSExpression: it crashes the process on "1+", does integer division
//  on "10/4", and answers 0 for "10/0". All three are measured behaviours of
//  the obvious Foundation approach, and all three are fixed here.
//

import Foundation
import XCTest
@testable import Calculate

final class CalculateTests: XCTestCase {

    // MARK: - The reasons this exists

    /// `NSExpression(format: "1+")` raises an uncatchable Objective-C
    /// exception and kills the process. This throws.
    func testAHalfTypedExpressionThrowsRatherThanCrashing() {
        for broken in ["1+", "1 +", "*", "2 * * 3", "(", "((", ")", "1 + + ", "^2"] {
            XCTAssertThrowsError(try Calculate.evaluate(broken), "\(broken) should throw") { error in
                XCTAssertTrue(error is CalculateError, "\(broken) threw \(type(of: error))")
            }
        }
        // And the process is still here to assert that.
        XCTAssertEqual(try? Calculate.evaluate("1+1"), 2)
    }

    /// `NSExpression` answers 2 for this, because both operands are integers.
    func testDivisionIsFloatingPointNotInteger() throws {
        XCTAssertEqual(try Calculate.evaluate("10/4"), 2.5, "NSExpression answers 2 here")
        XCTAssertEqual(try Calculate.evaluate("1/3"), 1.0 / 3.0, accuracy: 1e-12)
        XCTAssertEqual(try Calculate.evaluate("7/2"), 3.5)
    }

    /// `NSExpression` answers 0. Dividing by zero is an error, not a zero.
    func testDivisionByZeroIsAnError() {
        XCTAssertThrowsError(try Calculate.evaluate("10/0")) { error in
            XCTAssertEqual(error as? CalculateError, .divisionByZero)
        }
        XCTAssertThrowsError(try Calculate.evaluate("5 % 0")) { error in
            XCTAssertEqual(error as? CalculateError, .divisionByZero)
        }
    }

    /// A pathological nesting must be refused, not recursed into oblivion.
    func testDeepNestingIsRefusedRatherThanExhaustingTheStack() {
        let deep = String(repeating: "(", count: 5_000) + "1" + String(repeating: ")", count: 5_000)
        XCTAssertThrowsError(try Calculate.evaluate(deep)) { error in
            XCTAssertEqual(error as? CalculateError, .tooDeep)
        }
        XCTAssertEqual(try? Calculate.evaluate("((((1))))"), 1, "reasonable nesting still works")
    }

    // MARK: - Arithmetic

    func testPrecedenceAndParentheses() throws {
        XCTAssertEqual(try Calculate.evaluate("2 + 3 * 4"), 14, "times binds tighter than plus")
        XCTAssertEqual(try Calculate.evaluate("(2 + 3) * 4"), 20)
        XCTAssertEqual(try Calculate.evaluate("100 - 10 - 5"), 85, "minus is left-associative")
        XCTAssertEqual(try Calculate.evaluate("2 ^ 3 ^ 2"), 512, "power is RIGHT-associative: 2^(3^2)")
        XCTAssertEqual(try Calculate.evaluate("10 % 3"), 1)
        XCTAssertEqual(try Calculate.evaluate("2 + 3 * 4 ^ 2"), 50)
    }

    func testUnaryMinus() throws {
        XCTAssertEqual(try Calculate.evaluate("-5"), -5)
        XCTAssertEqual(try Calculate.evaluate("-5 + 3"), -2)
        XCTAssertEqual(try Calculate.evaluate("3 - -5"), 8)
        XCTAssertEqual(try Calculate.evaluate("-(3 + 4)"), -7)
        XCTAssertEqual(try Calculate.evaluate("--5"), 5)
    }

    func testTheSymbolsPeopleActuallyType() throws {
        XCTAssertEqual(try Calculate.evaluate("6 × 7"), 42)
        XCTAssertEqual(try Calculate.evaluate("6 x 7"), 42, "a lowercase x is a times sign to most people")
        XCTAssertEqual(try Calculate.evaluate("84 ÷ 2"), 42)
        XCTAssertEqual(try Calculate.evaluate("50 − 8"), 42, "a word-processor minus, not a hyphen")
        XCTAssertEqual(try Calculate.evaluate("[3 + 4] * 6"), 42, "brackets read as parentheses")
    }

    func testThousandsSeparatorsAreNoiseNotStructure() throws {
        XCTAssertEqual(try Calculate.evaluate("1,000 * 2"), 2000)
        XCTAssertEqual(try Calculate.evaluate("1,234,567 + 1"), 1_234_568)
        XCTAssertThrowsError(try Calculate.evaluate("1,,000"), "a stray comma is still an error")
    }

    func testDecimalsAndLeadingDots() throws {
        XCTAssertEqual(try Calculate.evaluate("2.5 * 4"), 10)
        XCTAssertEqual(try Calculate.evaluate(".5 + .5"), 1)
        XCTAssertEqual(try Calculate.evaluate("0.1 + 0.2"), 0.30000000000000004, accuracy: 1e-15)
    }

    func testAnEmptyExpressionIsItsOwnError() {
        XCTAssertEqual(try? Calculate.evaluate(""), nil)
        XCTAssertThrowsError(try Calculate.evaluate("   ")) { error in
            XCTAssertEqual(error as? CalculateError, .empty)
        }
    }

    func testTwoNumbersWithNoOperatorIsAnError() {
        // "5 5" must not quietly become 5, or 55.
        XCTAssertThrowsError(try Calculate.evaluate("5 5"))
        XCTAssertThrowsError(try Calculate.evaluate("(1)(2)"))
    }

    func testLettersAreRejectedWithTheirPosition() {
        XCTAssertThrowsError(try Calculate.evaluate("2 + abc")) { error in
            guard case .unexpectedCharacter(let character, let index) = error as? CalculateError else {
                return XCTFail("expected .unexpectedCharacter, got \(error)")
            }
            XCTAssertEqual(character, "a")
            XCTAssertEqual(index, 4, "positions are reported so a caller can underline the fault")
        }
    }

    // MARK: - Formatting

    func testResultsPrintTheWayPeopleWriteThem() {
        XCTAssertEqual(try? Calculate.evaluateToString("2+2"), "4", "not 4.0")
        XCTAssertEqual(try? Calculate.evaluateToString("10/4"), "2.5")
        XCTAssertEqual(try? Calculate.evaluateToString("0.1 + 0.2"), "0.3",
                       "binary floating point says 0.30000000000000004; nobody wants that")
        XCTAssertEqual(try? Calculate.evaluateToString("1/3"), "0.333333333333")
        XCTAssertEqual(try? Calculate.evaluateToString("-0"), "0")
    }

    func testValueOfReturnsNilRatherThanThrowingForTheCasualCaller() {
        XCTAssertEqual(Calculate.value(of: "2+2"), 4)
        XCTAssertNil(Calculate.value(of: "not maths"))
    }

    // MARK: - Numbers in prose

    func testNumbersAreFoundInOrdinarySentences() {
        let text = "spent 12.50, 8 and 30.25 on lunch"
        XCTAssertEqual(Numbers.all(in: text), [12.5, 8, 30.25])
        XCTAssertEqual(Numbers.sum(in: text), 50.75)
        XCTAssertEqual(Numbers.mean(in: text) ?? 0, 16.9166666, accuracy: 0.0001)
        XCTAssertEqual(Numbers.minimum(in: text), 8)
        XCTAssertEqual(Numbers.maximum(in: text), 30.25)
        XCTAssertEqual(Numbers.count(in: text), 3)
    }

    func testThousandsSeparatorsAndNegativesInProse() {
        XCTAssertEqual(Numbers.all(in: "revenue 1,250,000 and a loss of -4,300"), [1_250_000, -4_300])
        XCTAssertEqual(Numbers.sum(in: "1,000 and 2,000"), 3000)
    }

    /// A digit glued to letters is an identifier, not a quantity.
    func testIdentifiersAreNotNumbers() {
        XCTAssertEqual(Numbers.all(in: "order abc123 shipped"), [])
        XCTAssertEqual(Numbers.all(in: "model 123abc"), [])
        XCTAssertEqual(Numbers.all(in: "iPhone 15 costs 799"), [15, 799], "a standalone number still counts")
    }

    func testMedianTakesTheMiddleAndAveragesAnEvenCount() {
        XCTAssertEqual(Numbers.median(in: "1 2 3"), 2)
        XCTAssertEqual(Numbers.median(in: "1 2 3 4"), 2.5)
        XCTAssertEqual(Numbers.median(in: "10 1 5"), 5, "sorted first, not taken in order")
        XCTAssertNil(Numbers.median(in: "no numbers here"))
    }

    func testNoNumbersMeansNilNotZero() {
        XCTAssertNil(Numbers.sum(in: "nothing"))
        XCTAssertNil(Numbers.mean(in: ""))
        XCTAssertEqual(Numbers.count(in: "nothing"), 0)
    }

    // MARK: - Percentages

    func testTheFourPercentageQuestions() {
        XCTAssertEqual(Percentage.of(15, 200), 30)
        XCTAssertEqual(Percentage.what(30, of: 200), 15)
        XCTAssertEqual(Percentage.change(from: 200, to: 250), 25)
        XCTAssertEqual(Percentage.change(from: 250, to: 200), -20, "a fall is negative")
        XCTAssertEqual(Percentage.adding(15, to: 200), 230)
        XCTAssertEqual(Percentage.adding(-10, to: 200), 180, "a negative percent discounts")
    }

    func testPercentagesRefuseToDivideByZeroRatherThanReturningInfinity() {
        XCTAssertNil(Percentage.what(30, of: 0))
        XCTAssertNil(Percentage.change(from: 0, to: 100),
                     "every increase from nothing is infinite; a number there would be a lie")
    }

    func testChangeUsesTheMagnitudeOfTheStartSoNegativesDoNotInvert() {
        // From -100 to -50 is an improvement of 50, i.e. +50%.
        XCTAssertEqual(Percentage.change(from: -100, to: -50), 50)
    }
}

// MARK: - Percentage phrases

final class PercentageParsingTests: XCTestCase {

    func testPercentOf() {
        XCTAssertEqual(Percentage.evaluate("15% of 200"), 30)
        XCTAssertEqual(Percentage.evaluate("15 % of 200"), 30)
        XCTAssertEqual(Percentage.evaluate("15 percent of 200"), 30)
        XCTAssertEqual(Percentage.evaluate("20% of 1,000"), 200)
    }

    func testWhatPercent() {
        XCTAssertEqual(Percentage.evaluate("30 is what percent of 200"), 15)
        XCTAssertEqual(Percentage.evaluate("30 what % of 200"), 15)
    }

    func testAddingAndDiscounting() {
        XCTAssertEqual(Percentage.evaluate("200 + 15%"), 230)
        XCTAssertEqual(Percentage.evaluate("200 plus 15%"), 230)
        XCTAssertEqual(Percentage.evaluate("200 - 15%"), 170)
        XCTAssertEqual(Percentage.evaluate("200 minus 15%"), 170)
        XCTAssertEqual(Percentage.evaluate("200 less 15%"), 170)
    }

    func testChange() throws {
        let rise = try XCTUnwrap(Percentage.evaluate("from 80 to 100"))
        XCTAssertEqual(rise, 25, accuracy: 0.0001)
        let fall = try XCTUnwrap(Percentage.evaluate("from 100 to 80"))
        XCTAssertEqual(fall, -20, accuracy: 0.0001)
    }

    func testTheLongerQuestionWinsOverTheShorter() {
        // "what % of" ends in "% of". Matched the other way round, this
        // question would answer 30 rather than 15.
        XCTAssertEqual(Percentage.evaluate("30 is what percent of 200"), 15)
    }

    func testNotAPercentageQuestion() {
        XCTAssertNil(Percentage.evaluate("12 + 12"))
        XCTAssertNil(Percentage.evaluate("hello"))
        XCTAssertNil(Percentage.evaluate("100"))
        XCTAssertNil(Percentage.evaluate("10 % 3"))       // modulo, not percent
        XCTAssertNil(Percentage.evaluate("50% off everything"))
    }

    func testDivisionByZeroIsStillNil() {
        XCTAssertNil(Percentage.evaluate("30 is what percent of 0"))
        XCTAssertNil(Percentage.evaluate("from 0 to 100"))
    }
}
