//
//  FlagValue.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Foundation

public protocol FlagValue: Codable {

}

extension Bool: FlagValue {}
extension String: FlagValue {}
extension URL: FlagValue {}
extension Double: FlagValue {}
extension Float: FlagValue {}
extension Int: FlagValue {}
extension Int8: FlagValue {}
extension Int16: FlagValue {}
extension Int32: FlagValue {}
extension Int64: FlagValue {}
extension UInt: FlagValue {}
extension UInt8: FlagValue {}
extension UInt16: FlagValue {}
extension UInt32: FlagValue {}
extension UInt64: FlagValue {}

extension Array: FlagValue where Element: FlagValue {}
extension Dictionary: FlagValue where Key == String, Value: FlagValue {}
