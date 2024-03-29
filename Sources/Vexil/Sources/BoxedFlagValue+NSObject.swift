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

internal extension BoxedFlagValue {
    init?<Value>(object: Any, typeHint: Value.Type) where Value: FlagValue {
        switch object {
        case let value as Bool where typeHint.BoxedValueType == Bool.self || typeHint.BoxedValueType == Optional<Bool>.self:
            self = .bool(value)

        case let value as Data:             self = .data(value)
        case let value as Int:              self = .integer(value)
        case let value as Float:            self = .float(value)
        case let value as Double:           self = .double(value)
        case let value as String:           self = .string(value)
        case is NSNull:                     self = .none

        case let value as [Any]:            self = .array(value.compactMap { BoxedFlagValue(object: $0, typeHint: typeHint) })
        case let value as [String: Any]:    self = .dictionary(value.compactMapValues { BoxedFlagValue(object: $0, typeHint: typeHint) })

        default:
            return nil
        }
    }

    var object: NSObject {
        switch self {
        case let .array(value):         return value.map { $0.object } as NSArray
        case let .bool(value):          return value as NSNumber
        case let .data(value):          return value as NSData
        case let .dictionary(value):    return value.mapValues { $0.object } as NSDictionary
        case let .double(value):        return value as NSNumber
        case let .float(value):         return value as NSNumber
        case let .integer(value):       return value as NSNumber
        case .none:                     return NSNull()
        case let .string(value):        return value as NSString
        }
    }
}
