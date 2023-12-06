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
			.map { $0.matches.count }
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

	func partTwo() {
		var copies = [Int](repeating: 1, count: cards.count + 1)
		copies[0] = 0

		cards
			.filter { $0.wins > 0 }
			.forEach { card in
				let start = card.id + 1
				let end = card.id + card.wins

				(start...end)
					.forEach { index in
						copies[index] += copies[card.id]
					}
			 }

		let result = copies
			.reduce(0, +)

		print("result: \(result)")
	}

	static func parseCards(_ input: [String.SubSequence]) -> [Card] {
		var cardId = 0
		return input
			.map { $0.dropFirst(10) } // Remove Card prefix
			.map { $0.split(separator: "|") }
			.map { (numbers(from: $0.first!), numbers(from: $0.last!)) }
			.map {
				cardId += 1
				return Card(id: cardId, winningNumbers: $0.0, numbersOnCard: $0.1)
			}
	}

	static func numbers(from input: String.SubSequence) -> Set<Int> {
		let numbers = input
			.split(separator: " ")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
			.compactMap { Int($0) }

		return Set(numbers)
	}
}

class Card: CustomStringConvertible {
	let id: Int
	let winningNumbers: Set<Int>
	let numbersOnCard: Set<Int>
	let matches: Set<Int>
	var wins: Int { matches.count }
	var winFactor = 1

	var description: String { "Card(\(id))" }

	init(id: Int, winningNumbers: Set<Int>, numbersOnCard: Set<Int>) {
		self.id = id
		self.winningNumbers = winningNumbers
		self.numbersOnCard = numbersOnCard
		self.matches = winningNumbers.intersection(numbersOnCard)
	}
}

extension Card: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

extension Card: Equatable {
	static func == (lhs: Card, rhs: Card) -> Bool {
		lhs.id == rhs.id
	}
}
