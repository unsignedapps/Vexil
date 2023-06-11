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

/// A type-erasing protocol used so that `FlagPole`s and `Snapshot`s can pass
/// the necessary information so generic `Flag`s and `FlagGroup`s can "decorate" themselves
/// with a reference to where to lookup flag values and how to calculate their key.
///
//internal protocol Decorated {
//    func decorate(lookup: FlagLookup, label: String, codingPath: [String], config: VexilConfiguration)
//}
//
//internal extension Sequence<Mirror.Child> {
//
//    typealias DecoratedChild = (label: String, value: Decorated)
//
//    var decorated: [DecoratedChild] {
//        compactMap { child -> DecoratedChild? in
//            guard
//                let label = child.label,
//                let value = child.value as? Decorated
//            else {
//                return nil
//            }
//
//            return (label, value)
//        }
//
//        // all of our decorated items are property wrappers,
//        // so they'll start with an underscore
//        .map { child -> DecoratedChild in
//            (
//                label: child.label.hasPrefix("_") ? String(child.label.dropFirst()) : child.label,
//                value: child.value
//            )
//        }
//    }
//}
