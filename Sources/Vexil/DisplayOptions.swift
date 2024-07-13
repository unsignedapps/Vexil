//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

public enum VexilDisplayOption: Equatable {

    case hidden
    case navigation
    case section


    // MARK: - Conversion

    public init(_ flagDisplayOption: FlagDisplayOption) {
        switch flagDisplayOption {
        case .hidden:                       self = .hidden
        }
    }

}


// MARK: - Flag Display Options

public enum FlagDisplayOption {

    case hidden

}
