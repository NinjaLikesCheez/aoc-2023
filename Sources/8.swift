import Foundation
import RegexBuilder

typealias Network = [String: (left: String, right: String)]

struct PuzzleEight: Puzzle {
	let input = Self.fetchPuzzle("inputs/8")
	let network: Network
	let instructions: String.SubSequence

	init() {
		network = Self.generateNetwork(input)
		instructions  = input.first!
	}

	func partOne() {
		let steps = Self.steps(for: "AAA", instructions: instructions, in: network, shouldLoop: ({ $0 != "ZZZ"}))

		print("partOne: \(steps)")
	}

	func partTwo() {
		let currentNodes = network
			.keys
			.filter { $0.hasSuffix("A") }
			.map { String($0) }

		// Get the lengths to the end of the road for each of the nodes we're looking for
		// lengths: [20093, 14999, 16697, 20659, 22357, 17263]
		let lengths = currentNodes.map {
			Self.steps(for: $0, instructions: instructions, in: network, shouldLoop: ({ !$0.hasSuffix("Z")}))
		}
		print("lengths: \(lengths)")

		// Get the least common multiple i.e. the number required for all of the nodes to align at the end point at the same time
		// https://en.wikipedia.org/wiki/Least_common_multiple
		// 22103062509257
		print(lcm(lengths))
	}

	static func steps(
		for node: String,
		instructions: String.SubSequence,
		in network: Network,
		shouldLoop: (String) -> Bool
	) -> Int {
		var steps = 0
		var instructionIndex = instructions.startIndex
		var current = node

		while shouldLoop(current) {
			if instructionIndex >= instructions.endIndex {
				// If we run out of instructions, loop back to the first instruction
				instructionIndex = instructions.startIndex
			}

			let instruction = instructions[instructionIndex]

			switch instruction {
			case "L":
				current = network[current]!.left
			case "R":
				current = network[current]!.right
			default: fatalError("Bad instruction: \(instruction)")
			}

			instructionIndex = instructions.index(after: instructionIndex)
			steps += 1
		}

		return steps
	}

	static func generateNetwork(_ input: [String.SubSequence]) -> Network {
		let results =
			input
				.dropFirst()
				.map { line -> (Substring, (Substring, Substring)) in
					// NCT = (TRH, GJX)
					let split = line.split(separator: " = ")
					let second = split[1].dropFirst().dropLast().split(separator: ", ")
					return (split[0], (second[0], second[1]))
				}
				.map { (String($0.0), (String($0.1.0), String($0.1.1))) }

		return Dictionary(uniqueKeysWithValues: results)
	}
}

// Stolen from https://stackoverflow.com/questions/28349864/algorithm-for-lcm-of-doubles-in-swift
// GCD of two numbers:
func gcd(_ a: Int, _ b: Int) -> Int {
    var (a, b) = (a, b)
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return abs(a)
}

// GCD of a vector of numbers:
func gcd(_ vector: [Int]) -> Int {
    return vector.reduce(0, gcd)
}

// LCM of two numbers:
func lcm(a: Int, b: Int) -> Int {
    return (a / gcd(a, b)) * b
}

// LCM of a vector of numbers:
func lcm(_ vector : [Int]) -> Int {
    return vector.reduce(1, lcm)
}
