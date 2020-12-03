import Foundation

/// Reads in a file at a given location
public func parseFile<T>(at url: URL, transform: (String) -> T?) throws -> [T] {
    let fileContents = try String(contentsOf: url, encoding: .utf8)
    
    let lines = fileContents.components(separatedBy: .newlines)
    return lines.compactMap(transform)
}
