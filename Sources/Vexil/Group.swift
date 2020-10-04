//
//  FlagGroup.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

/// A wrapper representing a group of Feature Flags / Feature Toggles.
///
/// Use this to structure your flags into a tree. You can nest `FlagGroup`s as deep
/// as you need to and can split them across multiple files for maintainability.
///
/// The type that you wrap with `FlagGroup` must conform to `FlagContainer`.
///
@propertyWrapper
public struct FlagGroup<Group>: Decorated, Identifiable where Group: FlagContainer {

    /// All `FlagGroup`s are `Identifiable`
    public let id = UUID()

    /// A collection of information about this `FlagGroup` such as its display name and description.
    public let info: FlagInfo

    /// The `FlagContainer` being wrapped.
    public var wrappedValue: Group

    /// How we should display this group in Vexillographer
    public let display: Display


    // MARK: - Initialisation

    /// Initialises a new `FlagGroup` with the supplied info
    ///
    /// ```swift
    /// @FlagGroup(description: "This is a test flag group. Isn't it grand?"
    /// var myFlagGroup: MyFlags
    /// ```
    ///
    /// - Parameters:
    ///   - name:               An optional display name to give the group. Only visible in flag editors like Vexillographer.
    ///                         Default is to calculate one based on the property name.
    ///   - codingKeyStragey:   An optional strategy to use when calculating the key name for this group. The default is to use the `FlagPole`s strategy.
    ///   - description:        A description of this flag group. Used in flag editors like Vexillographer and also for future developer context.
    ///                         You can also specify `.hidden` to hide this flag group from Vexillographer.
    ///   - display:            Whether we should display this FlagGroup as using a `NavigationLink` or as a `Section` in Vexillographer
    ///
    public init (name: String? = nil, codingKeyStrategy: CodingKeyStrategy = .default, description: FlagInfo, display: Display = .navigation) {
        self.codingKeyStrategy = codingKeyStrategy
        self.wrappedValue = Group()
        self.display = display

        var info = description
        info.name = name
        self.info = info
    }


    // MARK: - Decoratod Conformance

    internal var decorator = Decorator()
    private let codingKeyStrategy: CodingKeyStrategy

    /// Decorates the receiver with the given lookup info.
    ///
    /// The `key` for this part of the flag tree is calculated during this step based on the supplied parameters. All info is passed through to
    /// any `Flag` or `FlagGroup` contained within the receiver.
    ///
    func decorate(lookup: Lookup, label: String, codingPath: [String], config: VexilConfiguration) {
        var action = self.codingKeyStrategy.codingKey(label: label)
        if action == .default {
            action = config.codingPathStrategy.codingKey(label: label)
        }

        var codingPath = codingPath

        switch action {
        case .append(let string):
            codingPath.append(string)

        case .skip:
            break

        // these actions shouldn't be possible in theory
        case .absolute, .default:
            assertionFailure("Invalid `CodingKeyAction` found when attempting to create key name for FlagGroup \(self)")

        }

        self.decorator.key = codingPath.joined(separator: config.separator)
        self.decorator.lookup = lookup

        Mirror(reflecting: self.wrappedValue)
            .children
            .lazy
            .decorated
            .forEach {
                $0.value.decorate(lookup: lookup, label: $0.label, codingPath: codingPath, config: config)
            }
    }
}


// MARK: - Group Display

public extension FlagGroup {

    /// How to display this group in Vexillographer
    ///
    enum Display {

        /// Displays this group using a `NavigationLink`. This is the default.
        ///
        /// In the navigated view the `name` is the cell's display name and the navigated view's
        /// title, and the `description` is displayed at the top of the navigated view.
        ///
        case navigation

        /// Displays this group using a `Section`
        ///
        /// The `name` of this FlagGroup is used as the Section's header, and the `description`
        /// as the Section's footer.
        ///
        case section

    }

}
