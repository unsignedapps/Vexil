//
//  FlagValueSource.swift
//  Vexil
//
//  Created by Rob Amos on 25/5/20.
//

import Combine
import Foundation

public protocol FlagValueSource {
    func flagValue<Value> (key: String) -> Value? where Value: FlagValue
    func setFlagValue<Value> (_ value: Value?, key: String) throws where Value: FlagValue

    var valuesDidChange: AnyPublisher<Void, Never>? { get }
}

public extension FlagValueSource {
    var valuesDidChange: AnyPublisher<Void, Never>? {
        return nil
    }
}
