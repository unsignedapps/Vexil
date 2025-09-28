//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2025 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Testing

extension Tag {

    /// Tags related to `BoxedFlagValue`
    @Tag
    static var boxing: Self

    /// Tests that exercise Codable conformance
    @Tag
    static var codable: Self

    /// Tests that exercise flag value copying
    @Tag
    static var copying: Self

    /// Tests that exercise the FlagValueDictionary
    @Tag
    static var dictionary: Self

    /// Tests that use a `FlagPole`
    @Tag
    static var pole: Self

    /// Tests that exercise flag value removing
    @Tag
    static var removing: Self

    /// Tests that exercise flag value saving
    @Tag
    static var saving: Self

    /// Tests that utilise a snapshot
    @Tag
    static var snapshot: Self

    /// Tests that use a `FlagValueSource`
    @Tag
    static var source: Self

    /// Tests that involve a `UserDefaults` object
    @Tag
    static var userDefaults: Self

}
