import Foundation

struct PuzzleSeven: Puzzle {
	var input = Self.fetchPuzzle("inputs/7")

	func partOne() {
		let result = Self.parseHands(input, jokers: false)
			.sorted(by: { $0.beats($1) })
			.reversed()
			.enumerated()
			// $0.offset is the index into the sorted array - +1 is the rank number
			.map { $0.element.winningAmount(rank: $0.offset + 1) }
			.reduce(0, +)

		// 251287184
		print("partOne: \(result)")
	}

	func partTwo() {
		let result = Self.parseHands(input, jokers: true)
			.sorted(by: { $0.beats($1) })
			.reversed()
			.enumerated()
			// $0.offset is the index into the sorted array - +1 is the rank number
			.map { $0.element.winningAmount(rank: $0.offset + 1) }
			.reduce(0, +)

		// 251287184
		print("partTwo: \(result)")
	}

	static func parseHands(_ input: [String.SubSequence], jokers: Bool) -> [Hand] {
		input
			.map {
				$0.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
			}
			.map { Hand(cards: $0[0], bid: Int(String($0[1]))!, jokers: jokers) }
	}
}

struct HandSolver {
	static func solve(_ cards: [PlayingCard], jokers: Bool) -> HandType {
		return jokers ? solveWithJokers(cards) : solve(cards)
	}

	static private func solveWithJokers(_ cards: [PlayingCard]) -> HandType {
		let jokers = cards.filter { $0 == .jack }.count

		if jokers == 0 {
			return solve(cards)
		}

		// Jokers are in play, figure out the type of the remaining cards
		let nonWildcards = cards.filter { $0 != .jack }
		let nonWildType = solve(nonWildcards)

		print("cards: \(cards)")
		print("jokers: \(jokers)")
		print("nonWildType: \(nonWildType)")

		switch (nonWildType, jokers) {
		case (.fourOfAKind, _): return .fiveOfAKind
		case (.fullHouse, _): return .fiveOfAKind
		case (.threeOfAKind, let joker):
			return joker == 1 ? .fourOfAKind : .fiveOfAKind
		case (.twoPair, _):
			// Joker has to be one - other cards are a 4 count
			return .fullHouse
		case (.onePair, let jokers):
			switch jokers {
			case 1: return .threeOfAKind
			case 2: return .fourOfAKind
			case 3: return .fiveOfAKind
			default: fatalError("Unhandled case")
			}
		case (.high, let jokers):
			switch jokers {
			case 1: return .onePair
			case 2: return .threeOfAKind
			case 3: return .fourOfAKind
			case 4: return .fiveOfAKind
			case 5: return .fiveOfAKind
			default: fatalError("Unhandled case")
			}
		default: fatalError("Unhandled type and joker count: \(nonWildType) \(jokers)")
		}

		fatalError("Shouldn't get here")
	}

	static private func solve(_ cards: [PlayingCard]) -> HandType {
		// Count all cards of the same face value in hand, then filter empty or single counts
		let values = cards
			.reduce(into: [PlayingCard: Int]()) { $0[$1, default: 0] += 1}
			.values
			.filter { $0 > 1 }

		// No values means there were not face cards that were more than one in the count
		guard !values.isEmpty else { return .high }

		switch values.count {
		case 1:
			// Only one card had multiple counts - it must be X of a kind
			switch values[0] {
			case 2: return .onePair
			case 3: return .threeOfAKind
			case 4: return .fourOfAKind
			case 5: return .fiveOfAKind
			default: fatalError("Unhandled value count type: \(values[0])")
			}
		case 2:
			// Mixed counts! Either a two pair or a full house
			switch (values[0], values[1]) {
			case (2, 2):
				return .twoPair
			case (3, 2), (2, 3):
				return .fullHouse
			default: fatalError("Unhandled mixed pair case. Don't do this!")
			}
		default: fatalError("Unhandled value count type. Don't do this!")
		}

		fatalError(
			"""
			You should never get here - how'd you get here? \
			Normally I hate fatalErrors() but you know... this is meant to be just for funsies
			"""
		)
	}
}

struct Hand {
	let cards: [PlayingCard]
	let bid: Int
	let type: HandType
	let jokers: Bool

	init(cards: String.SubSequence, bid: Int, jokers: Bool) {
		self.bid = bid
		self.jokers = jokers

		self.cards = cards
			.map { String($0) }
			.compactMap { PlayingCard(from: $0) }

		type = HandSolver.solve(self.cards, jokers: jokers)
	}

	func winningAmount(rank: Int) -> Int {
		bid * rank
	}

	func beats(_ other: Hand) -> Bool {
		if type > other.type {
			return true
		} else if type < other.type {
			return false
		}

		// Hand types are the same, high card is now in play
		for (ours, theirs) in zip(cards, other.cards) {
			if jokers, ours == .jack || theirs == .jack {
				// Special handling for part 2 - jacks are jokers and are the worst card
				if ours == .jack && theirs == .jack { continue }

				if ours == .jack {
					return false
				} else if theirs == .jack {
					return true
				}
			}

			if ours > theirs {
				return true
			} else if theirs > ours {
				return false
			}
		}

		// if we get here we are actually tied... Do we need to handle this case?
		return false
	}
}

enum PlayingCard: Comparable, CustomStringConvertible {
	case one
	case two
	case three
	case four
	case five
	case six
	case seven
	case eight
	case nine
	case ten
	case jack
	case queen
	case king
	case ace

	init(from value: String) {
		switch value {
		case "1": self = .one
		case "2": self = .two
		case "3": self = .three
		case "4": self = .four
		case "5": self = .five
		case "6": self = .six
		case "7": self = .seven
		case "8": self = .eight
		case "9": self = .nine
		case "T": self = .ten
		case "J": self = .jack
		case "Q": self = .queen
		case "K": self = .king
		case "A": self = .ace
		default: fatalError("Don't give bad input plz")
		}
	}

	var description: String {
		switch self {
		case .one: return "1"
		case .two: return "2"
		case .three: return "3"
		case .four: return "4"
		case .five: return "5"
		case .six: return "6"
		case .seven: return "7"
		case .eight: return "8"
		case .nine: return "9"
		case .ten: return "T"
		case .jack: return "J"
		case .queen: return "Q"
		case .king: return "K"
		case .ace: return "A"
		}
	}
}

enum HandType: CaseIterable, Comparable {
	case high
	case onePair
	case twoPair
	case threeOfAKind
	case fullHouse
	case fourOfAKind
	case fiveOfAKind
}
