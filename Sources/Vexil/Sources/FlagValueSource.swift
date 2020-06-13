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
    func flagValue<Value> (key: String) -> Value? where Value: FlagValue
    func setFlagValue<Value> (_ value: Value?, key: String) throws where Value: FlagValue

    #if !os(Linux)
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
