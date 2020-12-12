//: [Previous](@previous)

//: [Day 12](https://adventofcode.com/2020/day/12)

import Foundation

enum Action {
    case north(CGFloat)
    case south(CGFloat)
    case east(CGFloat)
    case west(CGFloat)
    case right(CGFloat)
    case left(CGFloat)
    case forward(CGFloat)
    
    var relativeDistance: CGFloat? {
        switch self {
        case .north(let amount), .east(let amount): return amount
        case .south(let amount), .west(let amount): return -amount
        default: return nil
        }
    }
    
    var relativeRotation: CGFloat? {
        // Using Mac CGAffineTransform rule - clockwise = positive
        switch self {
        case .right(let amount): return -amount
        case .left(let amount): return amount
        default: return nil
        }
    }
    
    var rotates: Bool {
        switch self {
        case .left, .right: return true
        default: return false
        }
    }
    
    var isVerticalMovement: Bool {
        switch self {
        case .north, .south: return true
        default: return false
        }
    }
    
    init?(_ action: String) {
        let splitIndex = action.index(after: action.startIndex)
        guard splitIndex != action.endIndex,
              let amount = Int(action[splitIndex...]).map(CGFloat.init) else {
            return nil
        }

        let code = action[..<splitIndex]
        
        switch code {
        case "N": self = .north(amount)
        case "S": self = .south(amount)
        case "E": self = .east(amount)
        case "W": self = .west(amount)
        case "R": self = .right(amount)
        case "L": self = .left(amount)
        case "F": self = .forward(amount)
        default:
            return nil
        }
    }
}

guard let routeFile = Bundle.main.url(forResource: "route", withExtension: "txt") else {
    exit(0)
}
let actions = try parseFile(at: routeFile, transform: Action.init)

protocol ManhattanCalculator {
    var location: CGPoint { get }
}

extension ManhattanCalculator {
    var manhattanDistance: Int {
        // Feels dirty relying on round, but I don't feel like doing integral grid rotation math
        // and this spits out the right answers
        Int(abs(round(location.x)) + abs(round(location.y)))
    }
}

enum NavigatorError: Error {
    case invalidRotationAmount(CGFloat)
    case invalidMovement
}

//: Problem 1

class Navigator: ManhattanCalculator {
    enum Heading: CGFloat {
        case north = 0
        case east = 90
        case south = 180
        case west = 270
        
        func updatedHeading(for action: Action) throws -> Heading {
            let rotationAmount: CGFloat
            switch action {
            case .right(let angle):
                rotationAmount = angle
            case .left(let angle):
                rotationAmount = -angle
            default:
                return self
            }
            
            var newAngle = rawValue + rotationAmount
            while (newAngle < 0) { newAngle += 360 }
            newAngle = newAngle.truncatingRemainder(dividingBy: 360)
            
            guard let newHeading = Heading(rawValue: newAngle) else {
                throw NavigatorError.invalidRotationAmount(newAngle)
            }

            return newHeading
        }
    }
    
    private (set) var location: CGPoint = .zero
    private var heading: Heading = .east
    private let route: [Action]
    
    init(route: [Action]) {
        self.route = route
    }
    
    func executeRoute() throws {
        for action in route {
            if action.rotates {
                heading = try heading.updatedHeading(for: action)
            } else {
                let relativeAction: Action
                if case let .forward(amount) = action {
                    switch heading {
                    case .north: relativeAction = .north(amount)
                    case .south: relativeAction = .south(amount)
                    case .east: relativeAction = .east(amount)
                    case .west: relativeAction = .west(amount)
                    }
                } else {
                    relativeAction = action
                }
                
                guard let relativeDistance = relativeAction.relativeDistance else {
                    throw NavigatorError.invalidMovement
                }
                let transform: CGAffineTransform
                if relativeAction.isVerticalMovement {
                    transform = CGAffineTransform(translationX: 0, y: relativeDistance)
                } else {
                    transform = CGAffineTransform(translationX: relativeDistance, y: 0)
                }

                location = location.applying(transform)
            }
        }
    }
}

let navigator = Navigator(route: actions)
try navigator.executeRoute()
print("Movement Manhattan Distance: \(navigator.manhattanDistance)")

//: Problem 2:

class WaypointNavigator: ManhattanCalculator {
    private (set) var shipLocation: CGPoint = .zero
    private (set) var waypointLocation: CGPoint = CGPoint(x: 10, y: 1)
    private let route: [Action]
    
    var location: CGPoint { shipLocation }
    
    init(route: [Action]) {
        self.route = route
    }

    func executeRoute() throws {
        for action in route {
            let waypointTransformer: CGAffineTransform
            let shipTransformer: CGAffineTransform
            if case let .forward(amount) = action {
                let transform = CGAffineTransform(translationX: (waypointLocation.x - shipLocation.x) * amount, y: (waypointLocation.y - shipLocation.y) * amount)
                shipTransformer = transform
                waypointTransformer = transform
            } else if let rotationAmount = action.relativeRotation  {
                shipTransformer = .identity
                waypointTransformer = CGAffineTransform(translationX: self.shipLocation.x, y: self.shipLocation.y)
                        .rotated(by: rotationAmount * .pi / 180)
                        .translatedBy(x: -self.shipLocation.x, y: -self.shipLocation.y) // Mac
            } else {
                guard let relativeDistance = action.relativeDistance else {
                    throw NavigatorError.invalidMovement
                }

                shipTransformer = .identity
                if action.isVerticalMovement {
                    waypointTransformer = CGAffineTransform(translationX: 0, y: relativeDistance)
                } else {
                    waypointTransformer = CGAffineTransform(translationX: relativeDistance, y: 0)
                }
            }
            
            shipLocation = shipLocation.applying(shipTransformer)
            waypointLocation = waypointLocation.applying(waypointTransformer    )
        }
    }

}

let waypointNavigator = WaypointNavigator(route: actions)
try waypointNavigator.executeRoute()
print("Waypoint Manhattan Distance: \(waypointNavigator.manhattanDistance)")


////: [Next](@next)
