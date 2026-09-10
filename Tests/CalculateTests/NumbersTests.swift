//
//  NumbersTests.swift
//  CalculateTests
//
//  Created by David Sherlock on 2026.
//
//  Ordinals, numbers in words, rounding to a step, and ranges — every test a
//  fixed input with one right answer a person could check by hand.
//

import Foundation
import XCTest
@testable import Calculate

final class OrdinalTests: XCTestCase {

    func testTheFirstTwentyFive() {
        let expected = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th",
                        "11th", "12th", "13th", "14th", "15th", "16th", "17th", "18th", "19th", "20th",
                        "21st", "22nd", "23rd", "24th", "25th"]
        XCTAssertEqual((1...25).map(Numbers.ordinal), expected)
    }

    func testTheTeensRuleSurvivesAHundred() {
        // 111th, 112th, 113th — the last digit says st/nd/rd and is wrong.
        XCTAssertEqual((101...113).map(Numbers.ordinal),
                       ["101st", "102nd", "103rd", "104th", "105th", "106th", "107th", "108th", "109th",
                        "110th", "111th", "112th", "113th"])
        XCTAssertEqual(Numbers.ordinal(1011), "1011th")
        XCTAssertEqual(Numbers.ordinal(1012), "1012th")
        XCTAssertEqual(Numbers.ordinal(1013), "1013th")
    }

    func testThousandsAndZero() {
        XCTAssertEqual(Numbers.ordinal(1000), "1000th")
        XCTAssertEqual(Numbers.ordinal(1001), "1001st")
        XCTAssertEqual(Numbers.ordinal(1002), "1002nd")
        XCTAssertEqual(Numbers.ordinal(1003), "1003rd")
        XCTAssertEqual(Numbers.ordinal(0), "0th")
    }

    func testNegativesKeepTheirSuffix() {
        XCTAssertEqual(Numbers.ordinal(-1), "-1st")
        XCTAssertEqual(Numbers.ordinal(-2), "-2nd")
        XCTAssertEqual(Numbers.ordinal(-11), "-11th")
        XCTAssertEqual(Numbers.ordinal(-22), "-22nd")
    }
}

final class SpelledOutTests: XCTestCase {

    func testTheSmallNumbers() {
        XCTAssertEqual(Numbers.spelledOut(0), "zero")
        XCTAssertEqual(Numbers.spelledOut(7), "seven")
        XCTAssertEqual(Numbers.spelledOut(13), "thirteen")
        XCTAssertEqual(Numbers.spelledOut(20), "twenty")
        XCTAssertEqual(Numbers.spelledOut(21), "twenty-one")
        XCTAssertEqual(Numbers.spelledOut(99), "ninety-nine")
    }

    func testHundredsSayAndInBritishAndNotInAmerican() {
        XCTAssertEqual(Numbers.spelledOut(100), "one hundred")
        XCTAssertEqual(Numbers.spelledOut(101), "one hundred and one")
        XCTAssertEqual(Numbers.spelledOut(101, style: .american), "one hundred one")
        XCTAssertEqual(Numbers.spelledOut(123), "one hundred and twenty-three")
        XCTAssertEqual(Numbers.spelledOut(123, style: .american), "one hundred twenty-three")
        XCTAssertEqual(Numbers.spelledOut(999), "nine hundred and ninety-nine")
    }

    func testThousandsAreJoinedByCommasAndAFinalAnd() {
        XCTAssertEqual(Numbers.spelledOut(1000), "one thousand")
        XCTAssertEqual(Numbers.spelledOut(1001), "one thousand and one")
        XCTAssertEqual(Numbers.spelledOut(1001, style: .american), "one thousand one")
        XCTAssertEqual(Numbers.spelledOut(1100), "one thousand, one hundred")
        XCTAssertEqual(Numbers.spelledOut(12_345), "twelve thousand, three hundred and forty-five")
        XCTAssertEqual(Numbers.spelledOut(12_345, style: .american), "twelve thousand three hundred forty-five")
        XCTAssertEqual(Numbers.spelledOut(1_000_000), "one million")
        XCTAssertEqual(Numbers.spelledOut(1_000_001), "one million and one")
        XCTAssertEqual(Numbers.spelledOut(1_000_012, style: .american), "one million twelve")
    }

    func testTheWholeOfInt() {
        XCTAssertEqual(
            Numbers.spelledOut(Int.max),
            "nine quintillion, two hundred and twenty-three quadrillion, three hundred and seventy-two trillion, "
                + "thirty-six billion, eight hundred and fifty-four million, seven hundred and seventy-five thousand, "
                + "eight hundred and seven"
        )
        XCTAssertTrue(Numbers.spelledOut(Int.min).hasPrefix("minus nine quintillion"))
        XCTAssertTrue(Numbers.spelledOut(Int.min).hasSuffix("eight hundred and eight"))
    }

    func testNegativesSayMinus() {
        XCTAssertEqual(Numbers.spelledOut(-7), "minus seven")
        XCTAssertEqual(Numbers.spelledOut(-1234, style: .american), "minus one thousand two hundred thirty-four")
    }

    func testDecimalsAreReadDigitByDigit() {
        XCTAssertEqual(Numbers.spelledOut(12.5), "twelve point five")
        XCTAssertEqual(Numbers.spelledOut(3.14), "three point one four")
        XCTAssertEqual(Numbers.spelledOut(3.14159, fractionDigits: 3), "three point one four two")
        XCTAssertEqual(Numbers.spelledOut(12.50), "twelve point five")
        XCTAssertEqual(Numbers.spelledOut(3.0), "three")
        XCTAssertEqual(Numbers.spelledOut(0.05), "zero point zero five")
        XCTAssertEqual(Numbers.spelledOut(-2.5), "minus two point five")
        XCTAssertEqual(Numbers.spelledOut(-0.001), "zero", "rounds to nothing; no minus on zero")
        XCTAssertEqual(Numbers.spelledOut(1234.5, style: .american), "one thousand two hundred thirty-four point five")
    }

    func testNonFiniteValuesAreNamed() {
        XCTAssertEqual(Numbers.spelledOut(Double.nan), "not a number")
        XCTAssertEqual(Numbers.spelledOut(Double.infinity), "infinity")
        XCTAssertEqual(Numbers.spelledOut(-Double.infinity), "minus infinity")
    }
}

final class StepRoundingTests: XCTestCase {

    func testToTheNearestHalfQuarterFiveTenAndHundred() throws {
        XCTAssertEqual(try Numbers.round(12.3, toNearest: 0.5), 12.5)
        XCTAssertEqual(try Numbers.round(12.7, toNearest: 0.5), 12.5)
        XCTAssertEqual(try Numbers.round(12.8, toNearest: 0.25), 12.75)
        XCTAssertEqual(try Numbers.round(12, toNearest: 5), 10)
        XCTAssertEqual(try Numbers.round(13, toNearest: 5), 15)
        XCTAssertEqual(try Numbers.round(1234, toNearest: 10), 1230)
        XCTAssertEqual(try Numbers.round(1234, toNearest: 100), 1200)
        XCTAssertEqual(try Numbers.round(1250, toNearest: 100), 1300)
    }

    func testExactMultiplesStayPut() throws {
        XCTAssertEqual(try Numbers.round(12.5, toNearest: 0.5), 12.5)
        XCTAssertEqual(try Numbers.round(100, toNearest: 100), 100)
        XCTAssertEqual(try Numbers.round(0, toNearest: 0.1), 0)
    }

    func testTenthsComeOutClean() throws {
        // round(1.06 / 0.1) * 0.1 in binary is 1.1000000000000001. Not here.
        let value = try Numbers.round(1.06, toNearest: 0.1)
        XCTAssertEqual(value, 1.1)
        XCTAssertEqual("\(value)", "1.1")
        XCTAssertEqual("\(try Numbers.round(2.675, toNearest: 0.01))", "2.68")
        XCTAssertEqual("\(try Numbers.round(0.3, toNearest: 0.1))", "0.3")
    }

    func testHalfwayGoesAwayFromZeroUnlessBankersIsAsked() throws {
        XCTAssertEqual(try Numbers.round(2.5, toNearest: 1), 3)
        XCTAssertEqual(try Numbers.round(3.5, toNearest: 1), 4)
        XCTAssertEqual(try Numbers.round(-2.5, toNearest: 1), -3)
        XCTAssertEqual(try Numbers.round(2.5, toNearest: 1, ties: .toNearestOrEven), 2)
        XCTAssertEqual(try Numbers.round(3.5, toNearest: 1, ties: .toNearestOrEven), 4)
        XCTAssertEqual(try Numbers.round(-2.5, toNearest: 1, ties: .toNearestOrEven), -2)
        XCTAssertEqual(try Numbers.round(1.25, toNearest: 0.5), 1.5)
        XCTAssertEqual(try Numbers.round(1.25, toNearest: 0.5, ties: .toNearestOrEven), 1)
    }

    func testNegativesRoundSymmetrically() throws {
        XCTAssertEqual(try Numbers.round(-12.3, toNearest: 0.5), -12.5)
        XCTAssertEqual(try Numbers.round(-1234, toNearest: 100), -1200)
        XCTAssertEqual(try Numbers.round(-0.04, toNearest: 0.1), 0, "and no minus zero")
        XCTAssertEqual("\(try Numbers.round(-0.04, toNearest: 0.1))", "0.0")
    }

    func testUpAndDownAreTowardsTheInfinities() throws {
        XCTAssertEqual(try Numbers.roundUp(12.1, toNearest: 0.5), 12.5)
        XCTAssertEqual(try Numbers.roundUp(12.5, toNearest: 0.5), 12.5)
        XCTAssertEqual(try Numbers.roundUp(-1.2, toNearest: 0.5), -1)
        XCTAssertEqual(try Numbers.roundDown(12.9, toNearest: 0.5), 12.5)
        XCTAssertEqual(try Numbers.roundDown(-1.2, toNearest: 0.5), -1.5)
        XCTAssertEqual(try Numbers.roundUp(1201, toNearest: 100), 1300)
        XCTAssertEqual(try Numbers.roundDown(1299, toNearest: 100), 1200)
    }

    func testABadStepIsRefused() {
        for step in [0.0, -1.0, Double.nan, Double.infinity] {
            XCTAssertThrowsError(try Numbers.round(1, toNearest: step), "\(step)") { error in
                guard case .badStep = error as? CalculateError else {
                    return XCTFail("wrong error for step \(step): \(error)")
                }
                XCTAssertTrue(error.localizedDescription.contains("positive number"))
            }
        }
        XCTAssertThrowsError(try Numbers.roundUp(1, toNearest: 0))
        XCTAssertThrowsError(try Numbers.roundDown(1, toNearest: -0.5))
    }

    func testNonFiniteValuesPassThrough() throws {
        XCTAssertTrue(try Numbers.round(Double.nan, toNearest: 1).isNaN)
        XCTAssertEqual(try Numbers.round(Double.infinity, toNearest: 1), .infinity)
    }
}

final class ParityAndRangeTests: XCTestCase {

    func testEvenAndOdd() {
        XCTAssertTrue(Numbers.isEven(0))
        XCTAssertTrue(Numbers.isEven(2))
        XCTAssertTrue(Numbers.isEven(-4))
        XCTAssertFalse(Numbers.isEven(7))
        XCTAssertTrue(Numbers.isOdd(7))
        XCTAssertTrue(Numbers.isOdd(-3))
        XCTAssertFalse(Numbers.isOdd(0))
        XCTAssertTrue(Numbers.isOdd(Int.max))
        XCTAssertTrue(Numbers.isEven(Int.min))
    }

    func testClamp() {
        XCTAssertEqual(Numbers.clamp(5, to: 0...10), 5)
        XCTAssertEqual(Numbers.clamp(-5, to: 0...10), 0)
        XCTAssertEqual(Numbers.clamp(15, to: 0...10), 10)
        XCTAssertEqual(Numbers.clamp(0.5, to: 0.0...1.0), 0.5)
        XCTAssertEqual(Numbers.clamp(1.5, to: 0.0...1.0), 1)
        XCTAssertEqual(Numbers.clamp(-0.5, to: 0.0...1.0), 0)
        XCTAssertEqual(Numbers.clamp(3, to: 3...3), 3)
    }

    func testMapForwards() throws {
        XCTAssertEqual(try Numbers.map(50, from: 0...100, to: 0...1), 0.5)
        XCTAssertEqual(try Numbers.map(0, from: 0...100, to: 0...1), 0)
        XCTAssertEqual(try Numbers.map(100, from: 0...100, to: 0...1), 1)
        XCTAssertEqual(try Numbers.map(25, from: 0...100, to: 10...20), 12.5)
        XCTAssertEqual(try Numbers.map(0, from: -1...1, to: 0...255), 127.5)
    }

    func testMapExtrapolatesAndRunsBackwards() throws {
        XCTAssertEqual(try Numbers.map(150, from: 0...100, to: 0...1), 1.5, "outside the source extrapolates")
        XCTAssertEqual(try Numbers.map(0.25, from: (0, 1), to: (100, 0)), 75, "a countdown")
        XCTAssertEqual(try Numbers.map(75, from: (100, 0), to: (0, 1)), 0.25, "a backwards source")
        XCTAssertEqual(try Numbers.map(-5, from: (-10, 0), to: (1, 0)), 0.5)
    }

    func testMapRefusesASourceWithNoWidth() {
        XCTAssertThrowsError(try Numbers.map(1, from: (5, 5), to: (0, 1))) { error in
            XCTAssertEqual(error as? CalculateError, .emptyRange)
            XCTAssertTrue(error.localizedDescription.contains("no width"))
        }
        XCTAssertThrowsError(try Numbers.map(1, from: 5...5, to: 0...1))
    }
}

final class MoreNumbersTests: XCTestCase {

    func testHundredsWithoutTens() {
        XCTAssertEqual(Numbers.spelledOut(500), "five hundred")
        XCTAssertEqual(Numbers.spelledOut(505), "five hundred and five")
        XCTAssertEqual(Numbers.spelledOut(550), "five hundred and fifty")
        XCTAssertEqual(Numbers.spelledOut(505, style: .american), "five hundred five")
    }

    func testEveryTensWord() {
        XCTAssertEqual([20, 30, 40, 50, 60, 70, 80, 90].map { Numbers.spelledOut($0) },
                       ["twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"])
    }

    func testEveryTeen() {
        XCTAssertEqual((10...19).map { Numbers.spelledOut($0) },
                       ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
                        "seventeen", "eighteen", "nineteen"])
    }

    func testEveryGroupNameAppears() {
        XCTAssertEqual(Numbers.spelledOut(1_000_000_000), "one billion")
        XCTAssertEqual(Numbers.spelledOut(1_000_000_000_000), "one trillion")
        XCTAssertEqual(Numbers.spelledOut(1_000_000_000_000_000), "one quadrillion")
        XCTAssertEqual(Numbers.spelledOut(1_000_000_000_000_000_000), "one quintillion")
    }

    func testAnEmptyMiddleGroupIsSkipped() {
        XCTAssertEqual(Numbers.spelledOut(1_000_100), "one million, one hundred")
        XCTAssertEqual(Numbers.spelledOut(2_000_000_003), "two billion and three")
    }

    func testFractionDigitsRoundBeforeSpeaking() {
        XCTAssertEqual(Numbers.spelledOut(2.999, fractionDigits: 2), "three")
        XCTAssertEqual(Numbers.spelledOut(2.999, fractionDigits: 3), "two point nine nine nine")
        XCTAssertEqual(Numbers.spelledOut(2.5, fractionDigits: 0), "three", "half away from zero, %f's rule")
        XCTAssertEqual(Numbers.spelledOut(12.5, fractionDigits: -3), "thirteen", "a negative count is treated as none")
    }

    func testRoundingAtAThousandthStep() throws {
        XCTAssertEqual("\(try Numbers.round(1.0005, toNearest: 0.001))", "1.001")
        XCTAssertEqual("\(try Numbers.round(9.9999, toNearest: 0.001))", "10.0")
    }

    func testRoundingLargeValues() throws {
        XCTAssertEqual(try Numbers.round(123_456_789, toNearest: 1_000_000), 123_000_000)
        XCTAssertEqual(try Numbers.round(1e12 + 5, toNearest: 10), 1e12 + 10)
    }

    func testRoundingToAFractionalStepOfAnInteger() throws {
        XCTAssertEqual(try Numbers.round(7, toNearest: 2.5), 7.5)
        XCTAssertEqual(try Numbers.round(6, toNearest: 2.5), 5)
    }

    func testIntegerClampBounds() {
        XCTAssertEqual(Numbers.clamp(Int.max, to: 0...10), 10)
        XCTAssertEqual(Numbers.clamp(Int.min, to: 0...10), 0)
    }

    func testMapWithANegativeTarget() throws {
        XCTAssertEqual(try Numbers.map(0.5, from: 0...1, to: -1...1), 0)
        XCTAssertEqual(try Numbers.map(1, from: (0, 1), to: (-10, -20)), -20)
    }

    func testTheSuffixRuleAlone() {
        XCTAssertEqual(Ordinals.suffix(for: 112), "th")
        XCTAssertEqual(Ordinals.suffix(for: 122), "nd")
        XCTAssertEqual(Ordinals.suffix(for: 3), "rd")
    }
}
