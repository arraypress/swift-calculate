//
//  BaseTests.swift
//  Calculate
//
//  Created by David Sherlock on 2026.
//

import XCTest
@testable import Calculate

final class BaseTests: XCTestCase {

    // MARK: - Reading

    func testPrefixesDecideTheBase() throws {
        XCTAssertEqual(try Numbers.value(of: "0xFF"), 255)
        XCTAssertEqual(try Numbers.value(of: "0b1010"), 10)
        XCTAssertEqual(try Numbers.value(of: "0o755"), 493)
        XCTAssertEqual(try Numbers.value(of: "255"), 255)
        XCTAssertEqual(try Numbers.value(of: "#FF0000"), 16711680, "a colour is hexadecimal")
    }

    func testSeparatorsAreIgnored() throws {
        XCTAssertEqual(try Numbers.value(of: "1_000_000"), 1_000_000)
        XCTAssertEqual(try Numbers.value(of: "0xDE AD BE EF"), 0xDEADBEEF)
        XCTAssertEqual(try Numbers.value(of: "0b1111_0000"), 240)
    }

    func testAnExplicitBaseOverridesTheAbsenceOfAPrefix() throws {
        XCTAssertEqual(try Numbers.value(of: "FF", from: 16), 255)
        XCTAssertEqual(try Numbers.value(of: "1010", from: 2), 10)
        XCTAssertEqual(try Numbers.value(of: "zz", from: 36), 1295)
    }

    func testNegativesKeepTheirSign() throws {
        XCTAssertEqual(try Numbers.value(of: "-0xFF"), -255)
        XCTAssertEqual(try Numbers.rebase("-255", to: 16), "-FF")
    }

    // MARK: - Writing

    func testRebasing() throws {
        XCTAssertEqual(try Numbers.rebase("0xFF", to: 2), "11111111")
        XCTAssertEqual(try Numbers.rebase("255", to: 16), "FF")
        XCTAssertEqual(try Numbers.rebase("255", to: 16, uppercase: false), "ff")
        XCTAssertEqual(try Numbers.rebase("0b11111111", to: 10), "255")
        XCTAssertEqual(try Numbers.rebase("493", to: 8, prefixed: true), "0o755")
    }

    func testGroupingMakesLongRunsReadable() throws {
        XCTAssertEqual(try Numbers.rebase("0xDEADBEEF", to: 2, grouped: true),
                       "1101 1110 1010 1101 1011 1110 1110 1111")
        XCTAssertEqual(try Numbers.rebase("255", to: 16, grouped: true), "FF", "short runs are left alone")
    }

    func testAllFourAtOnce() throws {
        let all = try Numbers.allBases("255")
        XCTAssertEqual(all.map(\.base), [.binary, .octal, .decimal, .hexadecimal])
        XCTAssertEqual(all.map(\.digits), ["11111111", "377", "255", "FF"])
    }

    // MARK: - Refusals

    func testDigitsMustBelongToTheBase() {
        // "2" is not a binary digit, and reading it as one would invent a value.
        XCTAssertThrowsError(try Numbers.value(of: "0b1012"))
        XCTAssertThrowsError(try Numbers.value(of: "FF", from: 10))
        XCTAssertThrowsError(try Numbers.value(of: "0x"), "a prefix with no digits is not a number")
        XCTAssertThrowsError(try Numbers.value(of: ""))
    }

    func testBasesOutsideTheAlphabetAreRefused() {
        XCTAssertThrowsError(try Numbers.rebase("255", to: 1))
        XCTAssertThrowsError(try Numbers.rebase("255", to: 37))
        XCTAssertThrowsError(try Numbers.value(of: "10", from: 64))
    }

    func testOverflowIsReportedRatherThanWrapped() {
        XCTAssertThrowsError(try Numbers.value(of: "0xFFFFFFFFFFFFFFFFFF")) { error in
            guard case .valueTooLarge = error as? CalculateError else {
                return XCTFail("expected valueTooLarge, got \(error)")
            }
        }
    }

    func testBaseNamesAreRead() {
        XCTAssertEqual(NumberBase(name: "hex"), .hexadecimal)
        XCTAssertEqual(NumberBase(name: "BINARY"), .binary)
        XCTAssertEqual(NumberBase(name: "8"), .octal)
        XCTAssertNil(NumberBase(name: "base64"))
    }
}
