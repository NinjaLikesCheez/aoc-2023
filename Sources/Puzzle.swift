import Foundation

protocol Puzzle {
	var input: [String.SubSequence] { get }

	func partOne()
	func partTwo()
}

extension Puzzle {
	static func fetchPuzzle(_ filename: String) -> [String.SubSequence] {
		try! String(contentsOf: URL(filePath: filename))
			.split(whereSeparator: \.isNewline)
	}
}
