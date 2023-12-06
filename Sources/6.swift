import Foundation
import RegexBuilder

struct PuzzleSix: Puzzle {
	let input = Self.fetchPuzzle("inputs/6")

	let startingSpeed = 0
	let speedIncrease = 1 // ms per ms button held

	func partOne() {
		let result = Self.partOneRaces(from: input)
			.map { winningCombos(of: $0) }
			.reduce(1, *)

		// 741000
		print("partOne: \(result)")
	}

	func winningCombos(of race: Race) -> Int {
		let combos = (0..<race.time)
			.filter { heldTime in
				let distanceTraveled = heldTime * (race.time - heldTime) // speed * (totalTime - timeHeld)
				return distanceTraveled > race.distance
			}

		return combos.count
	}

	static func partOneRaces(from input: [String.SubSequence]) -> [Race] {
		let times = input[0]
			.dropFirst(5)
			.split(separator: " ")
			.compactMap { Int($0) }

		let distances = input[1]
			.dropFirst(9)
			.split(separator: " ")
			.compactMap { Int($0) }

		return zip(times, distances)
			.map { Race(time: $0, distance: $1) }
	}

	func partTwo() {
		let result = winningCombos(of: Self.partTwoRace(from: input))
		// 741000
		print("partTwo: \(result)")
	}

	static func partTwoRace(from input: [String.SubSequence]) -> Race {
		let timeString = input[0]
			.dropFirst(5)
			.map { String($0) }
			.map { $0.replacingOccurrences(of: " ", with: "") }
			.reduce("", +)
		let time = Int(timeString)!

		let distanceString = input[1]
			.dropFirst(9)
			.map { String($0) }
			.map { $0.replacingOccurrences(of: " ", with: "") }
			.reduce("", +)
		let distance = Int(distanceString)!

		return Race(time: time, distance: distance)
	}
}

struct Race {
	let time: Int
	let distance: Int
}
