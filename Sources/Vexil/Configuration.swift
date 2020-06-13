//
//  Configuration.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

public struct VexilConfiguration {
    var codingPathStrategy: CodingKeyStrategy
    var prefix: String?
    var separator: String

    public init(codingPathStrategy: VexilConfiguration.CodingKeyStrategy = .default, prefix: String? = nil, separator: String = ".") {
        self.codingPathStrategy = codingPathStrategy
        self.prefix = prefix
        self.separator = separator
    }

    public static var `default`: VexilConfiguration {
        return VexilConfiguration()
    }
}


// MARK: - KeyNamingStrategy

public extension VexilConfiguration {
    enum CodingKeyStrategy {

        /// Follow the default behaviour. If you're applying this to a `Flag` or a `FlagGroup` this is
        /// an instruction to use the `FlagPole`'s setting. If you're applying this to the `FlagPole`
        /// it falls back to `.kebabcase`.
        case `default`

        /// Converts the property name into a kebab-case string. e.g. myPropertyName becomes my-property-name
        case kebabcase

        /// Converts the property name into a snake_case string. e.g. myPropertyName becomes my_property_name
        case snakecase

        /// Manually specifies the key name for this `Flag` or `FlagGroup`.
        case custom(String)

        func codingKey (label: String) -> String {
            switch self {
            case .kebabcase, .default:
                return label.convertedToSnakeCase(separator: "-")

            case .snakecase:
                return label.convertedToSnakeCase()

            case .custom(let custom):
                return custom
            }
        }
    }
}


// MARK: - KeyNamingStrategy - FlagGroup

public extension FlagGroup {
    enum CodingKeyStrategy {

        /// Follow the default behaviour applied to the `FlagPole`
        case `default`

        /// Converts the property name into a kebab-case string. e.g. myPropertyName becomes my-property-name
        case kebabcase

        /// Converts the property name into a snake_case string. e.g. myPropertyName becomes my_property_name
        case snakecase

        /// Skips this `FlagGroup` from the key generation
        case skip

        /// Manually specifies the key name for this `FlagGroup`.
        case custom(String)

        func codingKey (label: String) -> String? {
            switch self {
            case .default:              return nil
            case .kebabcase:            return label.convertedToSnakeCase(separator: "-")
            case .snakecase:            return label.convertedToSnakeCase()
            case .skip:                 return ""
            case .custom(let custom):   return custom
            }
        }
    }
}


// MARK: - KeyNamingStrategy - Flag

public extension Flag {
    enum CodingKeyStrategy {

        /// Follow the default behaviour applied to the `FlagPole`
        case `default`

        /// Converts the property name into a kebab-case string. e.g. myPropertyName becomes my-property-name
        case kebabcase

        /// Converts the property name into a snake_case string. e.g. myPropertyName becomes my_property_name
        case snakecase

        /// Manually specifies the key name for this `FlagGroup`.
        case custom(String)

        func codingKey (label: String) -> String? {
            switch self {
            case .default:              return nil
            case .kebabcase:            return label.convertedToSnakeCase(separator: "-")
            case .snakecase:            return label.convertedToSnakeCase()
            case .custom(let custom):   return custom
            }
        }
    }
}


// MARK: - Helper

private extension String {
    /// Returns a new string with the camel-case-based words of this string
    /// split by the specified separator.
    ///
    /// Examples:
    ///
    ///     "myProperty".convertedToSnakeCase()
    ///     // my_property
    ///     "myURLProperty".convertedToSnakeCase()
    ///     // my_url_property
    ///     "myURLProperty".convertedToSnakeCase(separator: "-")
    ///     // my-url-property
    func convertedToSnakeCase(separator: Character = "_") -> String {
        guard !isEmpty else { return self }
        var result = ""
        // Whether we should append a separator when we see a uppercase character.
        var separateOnUppercase = true
        for index in indices {
            let nextIndex = self.index(after: index)
            let character = self[index]
            if character.isUppercase {
                if separateOnUppercase && !result.isEmpty {
                    // Append the separator.
                    result += "\(separator)"
                }
                // If the next character is uppercase and the next-next character is lowercase, like "L" in "URLSession", we should separate words.
                separateOnUppercase = nextIndex < endIndex
                    && self[nextIndex].isUppercase
                    && self.index(after: nextIndex) < endIndex
                    && self[self.index(after: nextIndex)].isLowercase

            } else {
                // If the character is `separator`, we do not want to append another separator when we see the next uppercase character.
                separateOnUppercase = character != separator
            }
            // Append the lowercased character.
            result += character.lowercased()
        }
        return result
    }

}
