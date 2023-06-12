//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2023 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation

/// A configuration struct passed into the `FlagPole` to configure it.
///
public struct VexilConfiguration {

    /// The strategy to use when calculating the keys of all `Flag`s within the `FlagPole`.
    var codingPathStrategy: CodingKeyStrategy

    /// An optional prefix to apply to the calculated keys
    var prefix: String?

    /// A separator to use to `joined()` the different levels of the flag tree together.
    /// For example. If your separator is `/` and you access a flag via the KeyPath
    /// `flagPole.myGroup.secondGroup.someFlag` the "key" would be calculated as
    /// `my-group/second-group/some-flag`.
    ///
    var separator: String

    /// Initialises a new `VexilConfiguration` struct with the supplied info.
    ///
    /// - Parameters:
    ///   - codingPathStrategy:     How to calculate each `Flag`s "key". Defaults to `CodingKeyStrategy.default` (aka `.kebabcase`)
    ///   - prefix:                 An optional prefix to apply to each calculated key,. This is treated as a separate "level" of the tree.
    ///                             So if your prefix is "magic", your flag keys would be `magic.abc-flag`
    ///   - separator:              A separator to use by `joined()` to combine different levels of the flag tree together.
    ///
    public init(codingPathStrategy: VexilConfiguration.CodingKeyStrategy = .default, prefix: String? = nil, separator: String = ".") {
        self.codingPathStrategy = codingPathStrategy
        self.prefix = prefix
        self.separator = separator
    }

    /// The "default" `VexilConfiguration`
    ///
    public static var `default`: VexilConfiguration {
        VexilConfiguration()
    }
}


// MARK: - KeyNamingStrategy

public extension VexilConfiguration {

    /// An enumeration describing how keys should be calculated by `Flag` and `FlagGroup`s.
    ///
    /// Each `Flag` and `FlagGroup` can specify its own behaviour. This is the default behaviour
    /// to use when they don't.
    ///
    enum CodingKeyStrategy {

        /// Follow the default behaviour. This is basically a synonym for `.kebabcase`
        case `default`

        /// Converts the property name into a kebab-case string. e.g. myPropertyName becomes my-property-name
        case kebabcase

        /// Converts the property name into a snake_case string. e.g. myPropertyName becomes my_property_name
        case snakecase

//        internal func codingKey(label: String) -> CodingKeyAction {
//            switch self {
//            case .kebabcase, .default:
//                .append(label.convertedToSnakeCase(separator: "-"))
//
//            case .snakecase:
//                .append(label.convertedToSnakeCase())
//            }
//        }
    }
}


// MARK: - KeyNamingStrategy - FlagGroup

public extension VexilConfiguration {

    /// An enumeration describing how the key should be calculated for this specific `FlagGroup`.
    ///
    enum GroupKeyStrategy {

        /// Follow the default behaviour applied to the `FlagPole`
        case `default`

        /// Converts the property name into a kebab-case string. e.g. myPropertyName becomes my-property-name
        case kebabcase

        /// Converts the property name into a snake_case string. e.g. myPropertyName becomes my_property_name
        case snakecase

        /// Skips this `FlagGroup` from the key generation
        case skip

        /// Manually specifies the key name for this `FlagGroup`.
        case customKey(StaticString)

    }
}


// MARK: - KeyNamingStrategy - Flag

public extension VexilConfiguration {

    /// An enumeration describing how the key should be calculated for this specific `Flag`.
    ///
    enum FlagKeyStrategy {

        /// Follow the default behaviour applied to the `FlagPole`
        case `default`

        /// Converts the property name into a kebab-case string. e.g. myPropertyName becomes my-property-name
        case kebabcase

        /// Converts the property name into a snake_case string. e.g. myPropertyName becomes my_property_name
        case snakecase

        /// Manually specifies the key name for this `Flag`.
        ///
        /// This is combined with the keys from the parent groups to create the final key.
        ///
        case customKey(StaticString)

        /// Manually specifies a fully qualified key path for this flag.
        ///
        /// This is the absolute key name. It is NOT combined with the keys from the parent groups.
        case customKeyPath(StaticString)

//        internal func codingKey(label: String) -> CodingKeyAction {
//            switch self {
//            case .default:                      return .default
//            case .kebabcase:                    return .append(label.convertedToSnakeCase(separator: "-"))
//            case .snakecase:                    return .append(label.convertedToSnakeCase())
//            case let .customKey(custom):        return .append(custom)
//            case let .customKeyPath(custom):    return .absolute(custom)
//            }
//        }
    }
}


// MARK: - Coding Key Actions

/// An internal enum to give instructions to the key calculation steps on how a particular strategy should be applied
/// to the current process
///
// internal enum CodingKeyAction: Equatable {
//
//    /// Apply the default behaviour according to the current circumstances
//    case `default`
//
//    /// Skip the current component (only applies to groups)
//    case skip
//
//    /// Append the string to the key path
//    case append(StaticString)
//
//    /// Use the string as the absolute key path
//    case absolute(StaticString)
//
// }
