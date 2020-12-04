import Foundation

/// Reads in a file at a given location
public func parseFile<T>(at url: URL, separator: String = "\n", transform: (String) -> T?) throws -> [T] {
    let fileContents = try String(contentsOf: url, encoding: .utf8)
    
    let lines = fileContents.components(separatedBy: separator)
    return lines.compactMap(transform)
}
