// Game 1: 10 green, 9 blue, 1 red; 1 red, 7 green; 11 green, 6 blue; 8 blue, 12 green
import Foundation
import RegexBuilder

struct PuzzleTwo: Puzzle {
	let input: [String.SubSequence]
	let games: [Game]

	static let elfMaxCubes = Game.Cubes(red: 12, green: 13, blue: 14)

	init() {
		input = Self.fetchPuzzle("inputs/2")
		self.games = Self.games(from: input)
	}

	func partOne() {
		let result = games
			.filter {
				gameDoesNotExceedElfMaxCubes($0)
			}
			.map {
				$0.gameID
			}
			.reduce(0, +)

		print("partOne: \(result)")
	}

	func partTwo() {
		let result = games
			.map { $0.power }
			.reduce(0, +)

		print("partTwo: \(result)")
	}

	static func games(from input: [String.SubSequence]) -> [Game] {
		input
			.map { String($0) }
			.map { Game($0) }
	}

	func gameDoesNotExceedElfMaxCubes(_ game: Game) -> Bool {
		game.maxCubes.red.value <= Self.elfMaxCubes.red.value &&
		game.maxCubes.green.value <= Self.elfMaxCubes.green.value &&
		game.maxCubes.blue.value <= Self.elfMaxCubes.blue.value
	}
}

struct Game {
	let gameID: Int
	let maxCubes: Cubes
	let sets: [[CubeColor]]
	let power: Int

	struct Cubes {
		let red: CubeColor
		let green: CubeColor
		let blue: CubeColor

		init(red: Int, green: Int, blue: Int) {
			self.red = .red(red)
			self.green = .green(green)
			self.blue = .blue(blue)
		}
	}

	// Swift Regex still sucks, and anything more complicated than this kills the compiler a little
	static let gameIDRegex = Regex {
			"Game "
			TryCapture {
				OneOrMore(.digit)
			} transform: { match in
			 Int(match)
			}
		}

	init(_ line: String) {
		gameID = line.matches(of: Self.gameIDRegex)
			.map { $0.output.1 }
			.first!

		// Now, trim and split the string by the set
		guard let colonIndex = line.firstIndex(of: ":") else {
			fatalError("ill-formatted line")
		}

		let splits = line[line.index(colonIndex, offsetBy: 1)..<line.endIndex]
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.split(separator: ";")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}

		sets = splits
			.map {
				$0
					.split(separator: ",")
					.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			}
			.map {
				$0
					.map { CubeColor($0) }
			}

		// Calculate the max of all sets
		var red = 0
		var green = 0
		var blue = 0

		for colors in sets {
			for color in colors {
				switch color {
				case let .red(count):
					red = max(red, count)
				case let .green(count):
					green = max(green, count)
				case let .blue(count):
					blue = max(blue, count)
				}
			}
		}

		print(line)
		print("red: \(red), green: \(green), blue: \(blue)")
		maxCubes = .init(red: red, green: green, blue: blue)

		// Calculate the power of the max set
		power = red * green * blue
		print("power: \(power)")
		print("-----")
	}
}

extension Game {
	enum CubeColor {
		case green(Int)
		case red(Int)
		case blue(Int)

		init(_ part: String) {
			let regex = Regex {
				TryCapture {
					OneOrMore(.digit)
				} transform: { match in
					Int(match)
				}
				" "
				Capture {
					ChoiceOf {
						"green"
						"red"
						"blue"
					}
				}
			}

			guard
				let match = part.matches(of: regex).first
			else {
				fatalError("Failed to parse line: \(part)")
			}

			let (_, count, color) = match.output

			switch color {
			case "green":
				self = .green(count)
			case "red":
				self = .red(count)
			case "blue":
				self = .blue(count)
			default:
				fatalError("Unhandled case: \(color)")
			}
		}

		var value: Int {
			switch self {
			case let .red(value):
				return value
			case let .green(value):
				return value
			case let .blue(value):
				return value
			}
		}
	}
}
