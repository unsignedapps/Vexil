//
//  FlagInfo.swift
//  Vexil
//
//  Created by Rob Amos on 15/7/20.
//

public struct FlagInfo {

    // MARK: - Properties

    /// The name of the flag or flag group, if nil it is calculated from the containing property name
    public var name: String?

    /// A brief description of the flag or flag group's purpose
    public var description: String

    /// Whether or not the flag or flag group should be visible in Vexillographer
    public var shouldDisplay: Bool


    // MARK: - Initialisation

    init (name: String?, description: String, shouldDisplay: Bool) {
        self.name = name
        self.description = description
        self.shouldDisplay = shouldDisplay
    }

    public init (description: String) {
        self.init(name: nil, description: description, shouldDisplay: true)
    }
}


// MARK: - Hidden Flags

public extension FlagInfo {
    static let hidden = FlagInfo(name: nil, description: "", shouldDisplay: false)
}


// MARK: - String Literal Support

extension FlagInfo: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(name: nil, description: value, shouldDisplay: true)
    }
}
