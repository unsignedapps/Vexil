//
//  Flag+Mutability.swift
//  Vexil
//
//  Created by Rob Amos on 9/6/20.
//

import Combine

public class MutableFlag<Value> where Value: FlagValue {

    // MARK: - Properties

    internal let flag: Flag<Value>
    internal var value: Value? {
        didSet {
            self.isDirty = true
            self.valueDidChange.send()
        }
    }

    private var valueDidChange: SnapshotValueChanged

    internal var isDirty: Bool = false


    // MARK: - Initialisation

    internal init (flag: Flag<Value>, value: Value?, valueChanged: SnapshotValueChanged) {
        self.flag = flag
        self.value = value
        self.valueDidChange = valueChanged
    }


    // MARK: - Updating Sources

    internal func save (to source: FlagValueSource) throws {
        guard let key = self.key else { return }
        try source.setFlagValue(self.value, key: key)
    }
}
