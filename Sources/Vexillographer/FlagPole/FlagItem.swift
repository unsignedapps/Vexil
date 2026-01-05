//===----------------------------------------------------------------------===//
//
// This source file is part of the Vexil open source project
//
// Copyright (c) 2026 Unsigned Apps and the open source contributors.
// Licensed under the MIT license
//
// See LICENSE for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import SwiftUI
import Vexil

struct FlagItem<Value: FlagValue>: FlagPoleItem {

    var flag: FlagWigwag<Value>

    init(_ flag: FlagWigwag<Value>) {
        self.flag = flag
    }

    var isHidden: Bool {
        flag.displayOption == .hidden
    }

    var keyPath: FlagKeyPath {
        flag.keyPath
    }

    var name: String { flag.name }

    func makeContent() -> any View {
        FlagItemContent(wigwag: flag)
    }

}

struct FlagItemContent<Value: FlagValue>: View {

    var wigwag: FlagWigwag<Value>

    @State
    private var isShowingDetail = false
    @FocusState
    private var isFocused

    @Environment(\.flagPoleContext)
    private var flagPoleContext

    var body: some View {
        FlagControl(wigwag) { configuration in
            HStack {
                if let styledControl = flagPoleContext.styledControl(configuration: configuration) {
                    styledControl
                } else if configuration.isEditable {
                    DefaultFlagControl(configuration: configuration)
                } else {
                    FlagValueRow(configuration.name, value: configuration.value)
                }
                Button {
                    isFocused = false
                    isShowingDetail = true
                } label: {
                    Label("Info", systemImage: "info.circle")
                        .imageScale(.large)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.tint)
                        .symbolVariant(configuration.hasValue ? .fill : .none)
                }
                .buttonStyle(.plain)
            }
            .focused($isFocused)
#if !os(tvOS)
                .swipeActions(edge: .trailing) {
                    if configuration.hasValue {
                        Button {
                            configuration.resetValue()
                        } label: {
                            Label("Clear", systemImage: "trash.fill")
                                .imageScale(.large)
                        }
                        .tint(.red)
                    }
                }
#endif
                .sheet(isPresented: $isShowingDetail) {
                    NavigationView {
                        FlagDetailView(configuration: configuration)
                    }
                }
        }
    }
}

struct StyledFlagControl<Value: FlagValue>: View {
    var configuration: FlagControlConfiguration<Value>
    var style: any FlagControlStyle<Value>

    var body: some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

struct DefaultFlagControl: View {
    var content: any View

    init(configuration: FlagControlConfiguration<some FlagValue>) {
        switch configuration {
        case let configuration as any FlagToggleRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any OptionalBooleanFlagPickerRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any CaseIterableFlagPickerRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any OptionalCaseIterableFlagPickerRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any IntegerFlagTextFieldRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any OptionalIntegerFlagTextFieldRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any FloatingPointTextFieldRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any OptionalFloatingPointFlagTextFieldRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any StringFlagTextFieldRepresentable:
            self.content = configuration.makeContent()
        case let configuration as any OptionalStringFlagTextFieldRepresentable:
            self.content = configuration.makeContent()
        default:
            self.content = Text("Unimplemented \(configuration.name)").frame(maxWidth: .infinity)
        }
    }

    var body: some View {
        AnyView(content)
    }

}
