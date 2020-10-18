//
//  FlagDetailView.swift
//  Vexil: Vexilographer
//
//  Created by Rob Amos on 29/6/20.
//

// swiftlint:disable multiple_closures_with_trailing_closure

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
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
            Section(header: Text("Flag Details")) {
                HStack {
                    Text("Key").font(.headline)
                    Spacer()
                    Text(self.flag.info.key)
                }
                    .contextMenu {
                        Button(action: { self.flag.info.key.copyToPasteboard() }) {
                            Text("Copy key to clipboard")
                        }
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description").font(.headline)
                    Text(self.flag.info.description)
                }
                    .contextMenu {
                        Button(action: { self.flag.info.description.copyToPasteboard() }) {
                            Text("Copy description to clipboard")
                        }
                    }
            }

            Section(header: Text("Current Source")) {
                HStack {
                    Text(self.manager.source.name)
                        .font(.headline)
                    Spacer()
                    self.description(source: self.manager.source)
                }

                Button(action: self.clearValue) {
                    Text("Clear Flag Value in Current Source")
                }
                    .foregroundColor(.red)
                    .opacity(self.isCurrentSourceSet ? 1 : 0.3)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .disabled(self.isCurrentSourceSet == false)
                    .animation(.easeInOut, value: self.isCurrentSourceSet)
            }

            Section(header: Text("FlagPole Source Hierarchy")) {
                ForEach(self.manager.flagPole._sources, id: \.name) { source in
                    HStack {
                        if (source as AnyObject) === (self.manager.source as AnyObject) {
                            Text(source.name)
                                .font(.headline)
                        } else {
                            Text(source.name)
                        }
                        Spacer()
                        self.description(source: source)
                    }
                }
                HStack {
                    Text("Default Value")
                    Spacer()
                    FlagDisplayValueView(value: self.flag.flag.defaultValue)
                }
            }
        }
    }

    func description (source: FlagValueSource) -> some View {
        if let value = self.flagValue(source: source) {
            return FlagDisplayValueView(value: value).eraseToAnyView()
        } else {
            return Text("not set").italic().eraseToAnyView()
        }
    }

    func flagValue (source: FlagValueSource) -> Value? {
        return source.flagValue(key: self.flag.flag.key)
    }

    func clearValue () {
        try? self.manager.source.setFlagValue(Optional<Value>.none, key: self.flag.flag.key)        // swiftlint:disable:this syntactic_sugar
    }

    var isCurrentSourceSet: Bool {
        self.flagValue(source: self.manager.source) != nil
    }

}

#endif
