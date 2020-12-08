import Foundation

/// Reads in a file at a given location
public func parseFile<T>(at url: URL, separator: String = "\n", skipEmpty: Bool = true, transform: (String) -> T?) throws -> [T] {
    let fileContents = try String(contentsOf: url, encoding: .utf8)
    
    let lines = fileContents.components(separatedBy: separator)
    return lines.compactMap {
        if skipEmpty && $0.isEmpty {
            return nil
        }
        
        return transform($0)
    }
}
