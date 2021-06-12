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

/// A simple protocol that describes a source of `FlagValue`s
///
/// For more information and examples on creating custom `FlagValueSource`s please
/// see the full documentation.
///
public protocol FlagValueSource {

    /// The name of the source. Used by flag editors like Vexillographer
    var name: String { get }

    /// Provide a way to fetch values
    func flagValue<Value> (key: String) -> Value? where Value: FlagValue

    /// And to save values – if your source does not support saving just do nothing
    ///
    /// It is expected if the value passed in is `nil` then the flag value would be cleared
    ///
    func setFlagValue<Value> (_ value: Value?, key: String) throws where Value: FlagValue

    #if !os(Linux)

    /// If you're running on a platform that supports Combine you can optionally support real-time
    /// flag updates
    ///
    var valuesDidChange: AnyPublisher<Void, Never>? { get }

    #endif
}

#if !os(Linux)

/// Make support for real-time flag updates optional by providing a default nil implementation
///
public extension FlagValueSource {
    var valuesDidChange: AnyPublisher<Void, Never>? {
        return nil
    }
}

#endif
