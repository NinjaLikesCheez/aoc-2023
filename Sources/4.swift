import Foundation

struct PuzzleFour: Puzzle {
	let input: [String.SubSequence]
	let cards: [Card]

	init() {
		input = Self.fetchPuzzle("inputs/4")
		cards = Self.parseCards(input)
	}

	func partOne() {
		// For each card, get total of numbersOnCard in winningNumbers

		let score = cards
			.map { $0.winningNumbers.intersection($0.numbersOnCard).count }
			.map { total in
				var result = 0
				for _ in 0..<total {
					if result == 0 {
						result = 1
					} else {
						result *= 2
					}
				}
				return result
			}
			.reduce(0, +)

		print("Score: \(score)")
	}

	func partTwo() {}

	static func parseCards(_ input: [String.SubSequence]) -> [Card] {
		input
			.map { $0.dropFirst(10) } // Remove Card prefix
			.map { $0.split(separator: "|") }
			.map { (numbers(from: $0.first!), numbers(from: $0.last!)) }
			.map { Card(winningNumbers: $0.0, numbersOnCard: $0.1) }
	}

	static func numbers(from input: String.SubSequence) -> Set<Int> {
		let numbers = input
			.split(separator: " ")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
			.compactMap { Int($0) }

		return Set(numbers)
	}
}

struct Card {
	let winningNumbers: Set<Int>
	let numbersOnCard: Set<Int>
}
