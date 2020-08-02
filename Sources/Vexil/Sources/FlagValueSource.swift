//
//  FlagValueSource.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

#if !os(Linux)
import Combine
#endif

import Foundation

public protocol FlagValueSource {

    /// Give the source a name (for Vexillographer)
    var name: String { get }

    /// Provide a way to fetch values
    func flagValue<Value> (key: String) -> Value? where Value: FlagValue

    /// And to save values – if your source does not support saving just do nothing
    func setFlagValue<Value> (_ value: Value?, key: String) throws where Value: FlagValue

    #if !os(Linux)

    /// If you're running on a platform that supports Combine you can optionally support real-time
    /// flag updates
    ///
    var valuesDidChange: AnyPublisher<Void, Never>? { get }

    #endif
}

#if !os(Linux)

public extension FlagValueSource {
    var valuesDidChange: AnyPublisher<Void, Never>? {
        return nil
    }
}

#endif
