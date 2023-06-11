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

//#if !os(Linux)
//import Combine
//#endif
//
//extension Snapshot: Lookup {
//    func lookup<Value>(key: String, in source: FlagValueSource?) -> LookupResult<Value>? where Value: FlagValue {
//        lastAccessedKey = key
//        return values[key]?.toLookupResult()
//    }
//
//#if !os(Linux)
//
//    func publisher<Value>(key: String) -> AnyPublisher<Value, Never> where Value: FlagValue {
//        valuesDidChange
//            .compactMap { [weak self] _ in
//                self?.values[key] as? Value
//            }
//            .eraseToAnyPublisher()
//    }
//
//#endif
//}
