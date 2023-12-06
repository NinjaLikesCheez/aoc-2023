import Foundation

struct PartNumber {
	let startIndex: Int
	let endIndex: Int
	let number: Int
	let matrixOffset: Int

	func hasAdjacencies(in matrix: [[Character]]) -> Bool {
		var rowAbove: [Character]?
		var rowBelow: [Character]?
		let row = matrix[matrixOffset]
		print("--------------------------")

		let searchStart = startIndex == 0 ? startIndex : startIndex - 1
		let searchEnd = endIndex == row.endIndex ? endIndex : endIndex + 1

		var searchSpace = [[Character]]()

		if matrixOffset == 17 && number == 374 {
			print("break")
		}

		if matrixOffset != 0 {
			rowAbove = Array(matrix[matrixOffset - 1][searchStart..<searchEnd])
			searchSpace.append(rowAbove!)
		}

		let rowSpace = Array(row[searchStart..<searchEnd])
		searchSpace.append(rowSpace)

		if matrixOffset != (matrix.count - 1){
			rowBelow = Array(matrix[matrixOffset + 1][searchStart..<searchEnd])
			searchSpace.append(rowBelow!)
		}

		searchSpace
			.map { String($0) }
			.forEach { print($0) }

		if let rowAbove, !rowAbove.filter({ $0 != "." }).isEmpty {
			if rowAbove.filter(\.isNumber).count != 0 {
				fatalError("UHOH")
			}
			print("adj above")
			return true
		}

		if let rowBelow, !rowBelow.filter({ $0 != "." }).isEmpty {
			if rowBelow.filter(\.isNumber).count != 0 {
				fatalError("UHOH")
			}
			print("adj below")
			return true
		}

		if startIndex != 0, let first = rowSpace.first, first.isNumber {
			fatalError("UHOH")
		}

		if endIndex != row.count, let last = rowSpace.last, last.isNumber {
			fatalError("UHOH")
		}

		if rowSpace.first != "." || rowSpace.last != "." {
			print("adj on row")
			return true
		}

		return false




		// Row above
		if matrix.indices.contains(matrix.index(before: matrixOffset)) {
			rowAbove = matrix[matrix.index(before: matrixOffset)]

			let rowStart = rowAbove!.indices.contains(rowAbove!.index(before: startIndex)) ?
				rowAbove!.index(before: startIndex) :
				startIndex
			let rowEnd = rowAbove!.indices.contains(rowAbove!.index(after: endIndex)) ?
				rowAbove!.index(after: endIndex) :
				endIndex

			let elements = rowAbove![rowStart..<rowEnd]
			print("\(String(elements))")
			print(" \(String(row[startIndex..<endIndex]))")
			print("hasAdj? \(elements.filter { $0 != "."}.count != 0)")
			if !elements.filter({ $0 != "."}).isEmpty {
				return true
			}
		}

		// Row below
		if matrix.indices.contains(matrix.index(after: matrixOffset)) {
			rowBelow = matrix[matrix.index(after: matrixOffset)]

			let rowStart = rowBelow!.indices.contains(rowBelow!.index(before: startIndex)) ?
				rowBelow!.index(before: startIndex) :
				startIndex
			let rowEnd = rowBelow!.indices.contains(rowBelow!.index(after: endIndex)) ?
				rowBelow!.index(after: endIndex) :
				endIndex

			let elements = rowBelow![rowStart..<rowEnd]
			print(" \(String(row[startIndex..<endIndex]))")
			print("\(String(elements))")
			print("hasAdj? \(elements.filter { $0 != "."}.count != 0)")
			if !elements.filter({ $0 != "."}).isEmpty {
				return true
			}
		}

		// Current row
		if row.indices.contains(row.index(before: startIndex)), row[row.index(before: startIndex)] != "." {
			print("has char before: \(String(row[(startIndex - 1)..<endIndex]))")
			return true
		}

		if row.indices.contains(endIndex), row[endIndex] != "." {
			print("has char after: \(String(row[(startIndex)..<endIndex]))")
			return true
		}

		return false
	}
}

struct PuzzleThree: Puzzle {
	let input: [String.SubSequence]
	let matrix: [[Character]]
	let potentialParts: [[PartNumber]]

	init() {
		input = Self.fetchPuzzle("inputs/3")
		matrix = Self.parse(input)
		potentialParts = Self.potentialParts(matrix)
	}

	func partOne() {
		var parts = [PartNumber]()
		for line in potentialParts {
			for part in line where part.hasAdjacencies(in: matrix) {
				parts.append(part)
			}
		}

		let result = parts
			.map { $0.number }
			.reduce(0, +)

		print(parts.map { $0.number})
		print("part one: \(result)")
	}

	func partTwo() {

	}

	static func parse(_ input: [String.SubSequence]) -> [[Character]] {
		input
			.map { $0
				.enumerated()
				.map { $0.element }
			}
	}

	static func potentialParts(_ matrix: [[Character]]) -> [[PartNumber]] {
		var results = [[PartNumber]](repeating: [], count: matrix.count)

		for (matrixOffset, line) in matrix.enumerated() {
			var offset = 0
			while offset != line.endIndex {
				let character = line[offset]

				guard character.isNumber else {
					offset += 1
					continue
				}

				let numberStartIndex = offset
				var numberEndIndex = offset
				var numberString = "\(character)"

				// Find the end of the number we're in
				while let next = line.peek(after: offset) {
					guard next.character.isNumber else {
						numberEndIndex = offset
						break
					}

					numberString.append(next.character)
					offset += 1
					numberEndIndex = offset
				}

				let potentialPart = PartNumber(
					startIndex: numberStartIndex,
					endIndex: numberEndIndex + 1,
					number: Int(numberString)!,
					matrixOffset: matrixOffset
				)

				// Create our number representation
				results[matrixOffset].append(potentialPart)

				offset += 1
			}
		}

		return results
	}
}

extension [Character] {
	func peek(after index: Int) -> (index: Int, character: Character)? {
		let nextIndex = index + 1
		return indices.contains(nextIndex) ? (nextIndex, self[nextIndex]) : nil
	}
}
