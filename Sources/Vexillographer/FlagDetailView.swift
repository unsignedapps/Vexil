//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2024 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

#if os(iOS) || os(macOS)

import SwiftUI
import Vexil

@available(OSX 11.0, iOS 13.0, watchOS 7.0, tvOS 13.0, *)
struct FlagDetailView<Value, RootGroup>: View where Value: FlagValue, RootGroup: FlagContainer {

    // MARK: - Properties

    let flag: UnfurledFlag<Value, RootGroup>
    let isEditable: Bool

    @ObservedObject
    var manager: FlagValueManager<RootGroup>


    // MARK: - Initialisation

    init(flag: UnfurledFlag<Value, RootGroup>, manager: FlagValueManager<RootGroup>) {
        self.flag = flag
        self.manager = manager
        self.isEditable = manager.isEditable
    }


    // MARK: - View Body

#if os(iOS)

    var body: some View {
        content
            .navigationBarTitle(Text(flag.info.name), displayMode: .inline)
    }

#elseif os(macOS)

    var body: some View {
        ScrollView {
            content
        }
        .frame(minWidth: 300)
    }

#else

    var body: some View {
        content
    }

#endif


    var content: some View {
        Form {
            FlagDetailSection(header: Text("Flag Details")) {
                flagKeyView
                    .contextMenu {
                        CopyButton(action: flag.info.key.copyToPasteboard)
                    }

                VStack(alignment: .leading) {
                    Text("Description:").font(.headline)
                    Text(flag.info.description)
                }
                .contextMenu {
                    CopyButton(action: flag.info.description.copyToPasteboard)
                }
            }

            if manager.source != nil {
                FlagDetailSection(header: Text("Current Source")) {
                    HStack {
                        Text(manager.source!.flagValueSourceName)
                            .font(.headline)
                        Spacer()
                        description(source: manager.source!)
                    }

                    Button(action: clearValue) {
                        Text("Clear Flag Value in Current Source")
                    }
                    .foregroundColor(.red)
                    .opacity(isCurrentSourceSet ? 1 : 0.3)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .disabled(isCurrentSourceSet == false)
                    .animation(.easeInOut, value: isCurrentSourceSet)
                }
            }

            FlagDetailSection(header: Text("FlagPole Source Hierarchy")) {
                ForEach(manager.flagPole._sources, id: \.flagValueSourceName) { source in
                    HStack {
                        if (source as AnyObject) === (manager.source as AnyObject) {
                            Text(source.flagValueSourceName)
                                .font(.headline)
                        } else {
                            Text(source.flagValueSourceName)
                        }
                        Spacer()
                        description(source: source)
                    }
                }
                HStack {
                    Text("Default Value")
                    Spacer()
                    FlagDisplayValueView(value: flag.flag.defaultValue)
                }
            }
        }
    }

    func description(source: FlagValueSource) -> some View {
        if let value = flagValue(source: source) {
            FlagDisplayValueView(value: value).eraseToAnyView()
        } else {
            Text("not set").italic().eraseToAnyView()
        }
    }

    func flagValue(source: FlagValueSource) -> Value? {
        source.flagValue(key: flag.flag.key)
    }

    func clearValue() {
        try? manager.source?.setFlagValue(Value?.none, key: flag.flag.key)        // swiftlint:disable:this syntactic_sugar
    }

    var isCurrentSourceSet: Bool {
        guard let source = manager.source else {
            return false
        }
        return flagValue(source: source) != nil
    }

    private var flagKeyView: some View {
#if os(macOS)

        return VStack(alignment: .leading) {
            Text("Key").font(.headline)
            Text(flag.info.key)
        }

#else

        return HStack {
            Text("Key").font(.headline)
            Spacer()
            Text(flag.info.key)
        }

#endif
    }

}

#endif
