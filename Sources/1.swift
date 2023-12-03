import Foundation

struct PuzzleOne: Puzzle {
	let input: [String.SubSequence]

	init() {
		input = Self.fetchPuzzle("inputs/1")
	}

	func partOne() {
		// Find first and last numeric digits, 'combine' them where the first digit is the tens and the second digit is the ones, then add them all up
		let result = input
			.map {
				guard
					let first = $0.firstIndex(where: \.isNumber),
					let second = $0.lastIndex(where: \.isNumber),
					let firstDigit = Int(String($0[first])),
					let secondDigit = Int(String($0[second]))
				else { fatalError("Couldn't fetch indices") }

				return (firstDigit, secondDigit)
			}
			.compactMap {
				Int("\($0.0)\($0.1)")
			}
			.reduce(0, +)

		print("partOne: \(result)")
	}

	func partTwo() {
		// Find first and last numeric or textual digits, 'combine' them where the first digit is the tens and the second digit is the ones, then add them all up
		let result = input
			.map { $0.allIndicesOfDigits() }
			.compactMap { ($0.first!, $0.last!) }
			.compactMap { Int("\($0.0.1)\($0.1.1)") }
			.reduce(0, +)

		print("partTwo: \(result)")
	}
}

extension String.SubSequence {
	func allIndicesOfDigits() -> [(String.SubSequence.Index, Int)] {
		// ex: 14gxqgqsqqbxfpxnbccjc33eight
		var results = [(String.SubSequence.Index, Int)]()
		var substring = self

		// handle numbers
		while let index = substring.firstIndex(where: \.isNumber) {
			// print("sub: \(substring)")
			// Move search space
			results.append(
				(index, Int(String(substring[index]))!)
			)

			substring = substring[substring.index(after: index)..<substring.endIndex]
		}

		let stringsToDigits = [
			"one": 1,
			"two": 2,
			"three": 3,
			"four": 4,
			"five": 5,
			"six": 6,
			"seven": 7,
			"eight": 8,
			"nine": 9
		]

		// handle text - lol this is terrible
		for key in stringsToDigits.keys {
			substring = self
			while let range = substring.range(of: key) {
				// print("sub: \(substring)")
				// Move search space
				results.append((range.lowerBound, stringsToDigits[key]!))
				substring = substring[substring.index(after: range.lowerBound)..<substring.endIndex]
			}
		}

		return results.sorted(by: { $0.0 < $1.0 })
	}
}
