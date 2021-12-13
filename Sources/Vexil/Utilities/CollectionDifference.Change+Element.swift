//
//  CollectionDifference.Change+Element.swift
//  Vexil
//
//  Created by Rob Amos on 13/12/21.
//

extension CollectionDifference.Change {

    var element: ChangeElement {
        switch self {
        case .insert(offset: _, element: let element, associatedWith: _):           return element
        case .remove(offset: _, element: let element, associatedWith: _):           return element
        }
    }

}

