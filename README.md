# swift-calculate

Arithmetic over strings that cannot take your process down with it.

```swift
import Calculate

try Calculate.evaluate("10 / 4")        // 2.5
try Calculate.evaluate("(3 + 4) * 2")   // 14
try Calculate.evaluate("2^3^2")         // 512 — right-associative
Numbers.sum(in: "spent 12.50, 8 and 30.25")   // 50.75
Percentage.change(from: 200, to: 250)          // 25
```

## Why not `NSExpression`

The obvious Foundation route is `NSExpression(format:)`. Don't. Measured
2026-09-05:

```
"1+"     → CRASH. Uncaught NSException from +[NSPredicate predicateWithFormat:].
           It is an Objective-C exception, so Swift CANNOT catch it, and the
           process dies. A half-typed expression is a crash.
"10/4"   → 2.     Integer division on integer operands. Silently wrong.
"10/0"   → 0.     Not an error.
```

A character allowlist does not save you — all three of those are digits and
operators. This library parses by hand: every failure is a thrown
`CalculateError`, every division is floating point, and nesting is depth-capped
so a pathological `((((…` is refused rather than exhausting the stack.

That matters most where a crash is least acceptable: a keyboard extension
evaluating as you type.

## Expressions

```swift
try Calculate.evaluate("2 + 3 * 4")     // 14 — precedence
try Calculate.evaluate("100 - 10 - 5")  // 85 — left-associative
try Calculate.evaluate("2 ^ 3 ^ 2")     // 512 — power is RIGHT-associative
try Calculate.evaluate("10 % 3")        // 1
try Calculate.evaluate("-(3 + 4)")      // -7
try Calculate.evaluate("1,000 × 1.2")   // 1200
try Calculate.evaluate("[3 + 4] * 6")   // 42
```

`+ - * / % ^`, parentheses, unary minus, decimals, thousands separators, and
the symbols people actually type: `×` `÷` `x` for multiply, `−` for minus,
`[ ]` for brackets.

`Calculate.evaluateToString` formats the way a person writes it — `4` not
`4.0`, and `0.3` not `0.30000000000000004`.

## Numbers in prose

The other half. Not a stats tool over a column — the input is a sentence:

```swift
Numbers.all(in: "spent 12.50, 8 and 30.25")  // [12.5, 8, 30.25]
Numbers.sum(in: text)      // 50.75
Numbers.mean(in: text)
Numbers.median(in: text)   // sorted first; averages the middle two
Numbers.minimum(in: text)
Numbers.count(in: text)
```

A digit glued to letters is an identifier, not a quantity — `order abc123`
contributes nothing. No numbers returns `nil`, never a sum of zero.

## Percentages

Named after the question, because getting one the wrong way round is the usual
bug:

```swift
Percentage.of(15, 200)               // 30    — 15% of 200
Percentage.what(30, of: 200)         // 15    — 30 is what % of 200
Percentage.change(from: 200, to: 250) // 25   — negative for a fall
Percentage.adding(15, to: 200)       // 230
```

A total of zero returns `nil` rather than an infinity: every increase from
nothing is infinite, and a number there would be a lie.

## Tested

22 tests, all offline and instant. Three are named after the `NSExpression`
failures above and exist purely to keep them fixed.

## Requirements

macOS 14+ / iOS 16+ / tvOS 16+ / watchOS 9+ · Swift 6 · **no dependencies**

Foundation only, so it is safe inside a keyboard extension's memory budget.

## Installation

```swift
.package(url: "https://github.com/arraypress/swift-calculate.git", from: "0.1.0")
```

## Licence

MIT
