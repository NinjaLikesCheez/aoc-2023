import Foundation
import RegexBuilder

struct Seed {
	let number: Int
}

struct PuzzleFive: Puzzle {
	let input: [String.SubSequence]
	let seeds: [Seed]

	init() {
		input = Self.fetchPuzzle("inputs/5")
		seeds = Self.parseSeeds(input)
	}

	func number(from values: [MapValue], source: Int) -> Int {
		values
			.compactMap { $0.destination(for: source) }
			.first ?? source
	}

	// func numbers(from values: [MapValue], range: Range<Int>) -> Range<Int> {
	// 	values
	// 		.compactMap { $0.destinations(for: range) }
	// 		.first ?? range
	// }

	func partOne() {
		// These maps convert numbers from source to destinations:
		//  Destination Start Range, Source Range Start, Range Length
		// i.e. 10 40 2 will result in destinations 10 11 map to sources 40 41
		let maps = Self.parseMaps(input.dropFirst(2))

		let locations = seeds
			.map { number(from: maps[.seedToSoil]!, source: $0.number) }
			.map { number(from: maps[.soilToFertilizer]!, source: $0) }
			.map { number(from: maps[.fertilizerToWater]!, source: $0) }
			.map { number(from: maps[.waterToLight]!, source: $0) }
			.map { number(from: maps[.lightToTemperature]!, source: $0) }
			.map { number(from: maps[.temperatureToHumidity]!, source: $0) }
			.map { number(from: maps[.humidityToLocation]!, source: $0) }

		print("partOne: \(locations.sorted().first!)")
	}

	func partTwo() {
		let seedRanges = partTwoSeeds()
		let maps = Self.parseMaps(input.dropFirst(2))

		// TODO: This is ridiculous, if you have time rewrite this to not suck...
		var finalLocations = [Int]()
		for range in seedRanges {
			let locations = range
				.map { number(from: maps[.seedToSoil]!, source: $0) }
				.map { number(from: maps[.soilToFertilizer]!, source: $0) }
				.map { number(from: maps[.fertilizerToWater]!, source: $0) }
				.map { number(from: maps[.waterToLight]!, source: $0) }
				.map { number(from: maps[.lightToTemperature]!, source: $0) }
				.map { number(from: maps[.temperatureToHumidity]!, source: $0) }
				.map { number(from: maps[.humidityToLocation]!, source: $0) }

			finalLocations.append(locations.sorted().first!)
		}

		print("done: \(finalLocations.sorted().first!)")
}

	func partTwoSeeds() -> [Range<Int>] {
		let line = input
			.first!
			.dropFirst(7)

			let regex = Regex {
				TryCapture { OneOrMore(.digit) } transform: { Int($0) }
				One(.whitespace)
				TryCapture { OneOrMore(.digit) } transform: { Int($0) }
			}

			var results = [Range<Int>]()

			for match in line.matches(of: regex) {
				print("match.output: \(match.output)")
				let (_, start, length) = match.output

				results.append(start ..< start + length)
			}

			return results
	}

	static func parseSeeds(_ input: [String.SubSequence]) -> [Seed] {
		// seeds
		// seed-to-soil map
		// soil-to-fertilizer map
		// fertilizer-to-water map
		// water-to-light map
		// light-to-temperature map
		// temperature-to-humidity map
		// humidity-to-location map
		let seeds = input
			.first!
			.dropFirst(7)
			.split(separator: " ")
			.map { String($0) }
			.compactMap { Int($0) }
			.map { Seed(number: $0) }

		return seeds
	}

	static func parseMaps(_ input: ArraySlice<String.SubSequence>) -> [MapKey: [MapValue]] {
		var results = [MapKey: [MapValue]]()
		var currentSection: MapKey = .seedToSoil

		let mapRegex = Regex {
				TryCapture { OneOrMore(.digit) } transform: { Int($0) }
				OneOrMore(.whitespace)
				TryCapture { OneOrMore(.digit) } transform: { Int($0) }
				OneOrMore(.whitespace)
				TryCapture { OneOrMore(.digit) } transform: { Int($0) }
			}

	// TODO: clean up
		for line in input {
			if let section = MapKey(rawValue: String(line)) {
				currentSection = section
				print("NEW SECTION: \(section) -- \(line)")
				continue
			}

			for match in line.matches(of: mapRegex) {
				let (_, destinationStart, sourceStart, length) = match.output

				if results[currentSection] == nil {
					results[currentSection] = []
				}

				let value = MapValue(destinationStart: destinationStart, sourceStart: sourceStart, length: length)
				results[currentSection]!.append(value)
			}
		}

		return results
	}
}

struct SeedToSoils {
	let destinationRanges: [Range<Int>]
	let sourceRanges: [Range<Int>]
}

enum MapKey: String {
	case seedToSoil = "seed-to-soil map:"
	case soilToFertilizer = "soil-to-fertilizer map:"
	case fertilizerToWater = "fertilizer-to-water map:"
	case waterToLight = "water-to-light map:"
	case lightToTemperature = "light-to-temperature map:"
	case temperatureToHumidity = "temperature-to-humidity map:"
	case humidityToLocation = "humidity-to-location map:"
}

struct MapValue {
	var destinationStart: Int
	var sourceStart: Int
	var length: Int
}

extension MapValue {
	var destinationRange: Range<Int> { destinationStart ..< destinationStart + length }
	var sourceRange: Range<Int> { sourceStart ..< sourceStart + length }

	func destination(for source: Int) -> Int? {
		guard sourceRange.contains(source) else { return nil }

		let distance = sourceRange.distance(from: sourceStart, to: source)
		return destinationRange[destinationStart + distance]
	}
}
