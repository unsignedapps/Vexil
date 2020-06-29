//
//  FlagContainer+Extensions.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 15/6/20.
//

import Foundation
import Vexil

protocol Unfurlable {
    func unfurl<RootGroup> (label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem where RootGroup: FlagContainer
}

extension Flag: Unfurlable {
    func unfurl<RootGroup> (label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem where RootGroup: FlagContainer {
        return UnfurledFlag(name: label.localizedPropertyDisplayName, flag: self, manager: manager)
    }
}

extension FlagGroup: Unfurlable {
    func unfurl<RootGroup>(label: String, manager: FlagValueManager<RootGroup>) -> UnfurledFlagItem where RootGroup : FlagContainer {
        return UnfurledFlagGroup(name: label.localizedPropertyDisplayName, group: self, manager: manager)
    }
}

extension String {
    var localizedPropertyDisplayName: String {
        return self.propertyDisplayName(with: Locale.autoupdatingCurrent)
    }

    var propertyDisplayName: String {
        return self.propertyDisplayName(with: nil)
    }

    func propertyDisplayName (with locale: Locale?) -> String {
        let uppercased = CharacterSet.uppercaseLetters
        return (self.hasPrefix("_") ? String(self.dropFirst()) : self)
            .separatedAtWordBoundaries
            .map { CharacterSet(charactersIn: $0).isStrictSubset(of: uppercased) ? $0 : $0.capitalized(with: locale) }
            .joined(separator: " ")
    }

    /// Separates a string at word boundaries, eg. `oneTwoThree` becomes `one Two Three`
    ///
    /// Capital characters are determined by testing membership in `CharacterSet.uppercaseLetters` and `CharacterSet.lowercaseLetters` (Unicode General Categories Lu and Lt).
    /// The conversion to lower case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
    ///
    /// Adapted from JSONEncoder's `toSnakeCase()`
    ///
    var separatedAtWordBoundaries: [String] {
        guard !self.isEmpty else { return [] }

        let string = self

        var words : [Range<String.Index>] = []
        // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
        //
        // myProperty -> my_property
        // myURLProperty -> my_url_property
        //
        // We assume, per Swift naming conventions, that the first character of the key is lowercase.
        var wordStart = string.startIndex
        var searchRange = string.index(after: wordStart)..<string.endIndex

        // Find next uppercase character
        while let upperCaseRange = string.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
            let untilUpperCase = wordStart..<upperCaseRange.lowerBound
            words.append(untilUpperCase)

            // Find next lowercase character
            searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
            guard let lowerCaseRange = string.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
                // There are no more lower case letters. Just end here.
                wordStart = searchRange.lowerBound
                break
            }

            // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
            let nextCharacterAfterCapital = string.index(after: upperCaseRange.lowerBound)
            if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                // The next character after capital is a lower case character and therefore not a word boundary.
                // Continue searching for the next upper case for the boundary.
                wordStart = upperCaseRange.lowerBound
            } else {
                // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                let beforeLowerIndex = string.index(before: lowerCaseRange.lowerBound)
                words.append(upperCaseRange.lowerBound..<beforeLowerIndex)

                // Next word starts at the capital before the lowercase we just found
                wordStart = beforeLowerIndex
            }
            searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
        }
        words.append(wordStart..<searchRange.upperBound)

        return words.map({ (range) in
            return string[range].lowercased()
        })
    }
}
