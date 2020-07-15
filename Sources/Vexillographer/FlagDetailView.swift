//
//  FlagDetailView.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

struct FlagDetailView<Value, RootGroup>: View where Value: FlagValue, RootGroup: FlagContainer {

    // MARK: - Properties

    let flag: UnfurledFlag<Value, RootGroup>

    @ObservedObject var manager: FlagValueManager<RootGroup>


    // MARK: - Initialisation

    init (flag: UnfurledFlag<Value, RootGroup>, manager: FlagValueManager<RootGroup>) {
        self.flag = flag
        self.manager = manager
    }


    // MARK: - View Body

    #if os(iOS)

    var body: some View {
        self.content
            .navigationBarTitle(Text(self.flag.info.name), displayMode: .inline)
    }

    #else

    var body: some View {
        self.content
    }

    #endif


    var content: some View {
        Form {
            Section(header: Text("Description")) {
                Text(self.flag.info.description)
            }

            Section(header: Text("Current Source")) {
                HStack {
                    Text(self.manager.source.name)
                    Spacer()
                    self.description(source: self.manager.source)
                }
                if self.flagValue(source: self.manager.source) != nil {
                    HStack {
                        Button(action: self.clearValue) {
                            Text("Clear Flag Value in Current Source")
                                .foregroundColor(.red)
                        }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    }
                }
            }

            Section(header: Text("FlagPole Source Hierarchy")) {
                ForEach(0 ..< self.manager.flagPole._sources.count) { index in
                    HStack {
                        Text(self.manager.flagPole._sources[index].name)
                        Spacer()
                        self.description(source: self.manager.flagPole._sources[index])
                    }
                }
                HStack {
                    Text("Default Value")
                    Spacer()
                    Text(String(describing: self.flag.flag.defaultValue))
                }
            }
        }
    }

    func description (source: FlagValueSource) -> some View {
        if let value = self.flagValue(source: source) {
            return Text(String(describing: value))
        } else {
            return Text("not set").italic()
        }
    }

    func flagValue (source: FlagValueSource) -> Value? {
        return source.flagValue(key: self.flag.flag.key)
    }

    func clearValue () {
        try? self.manager.source.setFlagValue(Optional<Value>.none, key: self.flag.flag.key)        // swiftlint:disable:this syntactic_sugar
    }
}

#endif
