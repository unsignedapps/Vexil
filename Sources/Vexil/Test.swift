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

@FlagContainer
struct TestFlags {

    @Flag(default: false, description: "Top level test flag")
    var topLevelFlag: Bool

    @Flag(default: false, description: "Second test flag")
    var secondTestFlag: Bool

//    @FlagGroup(description: "Subgroup of test flags")
//    var subgroup: SubgroupFlags

}

@FlagContainer
struct SubgroupFlags {

    @Flag(default: false, description: "Second level test flag")
    var secondLevelFlag: Bool

//    @FlagGroup(description: "Another level of test flags")
//    var doubleSubgroup: DoubleSubgroupFlags

}

@FlagContainer
struct DoubleSubgroupFlags {

//    @Flag(default: false, description: "Third level test flag")
//    var thirdLevelFlag: Bool

}
