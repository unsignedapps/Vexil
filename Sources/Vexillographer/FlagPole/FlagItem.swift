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
    
    @State private var isShowingDetail = false
    @FocusState private var isFocused
    
    @Environment(\.flagPoleContext) var flagPoleContext
    
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
    
    init<Value: FlagValue>(configuration: FlagControlConfiguration<Value>) {
        switch configuration {
        case let configuration as any FlagToggleRepresentable:
            content = configuration.makeContent()
        case let configuration as any OptionalBooleanFlagPickerRepresentable:
            content = configuration.makeContent()
        case let configuration as any CaseIterableFlagPickerRepresentable:
            content = configuration.makeContent()
        case let configuration as any OptionalCaseIterableFlagPickerRepresentable:
            content = configuration.makeContent()
        case let configuration as any IntegerFlagTextFieldRepresentable:
            content = configuration.makeContent()
        case let configuration as any OptionalIntegerFlagTextFieldRepresentable:
            content = configuration.makeContent()
        case let configuration as any FloatingPointTextFieldRepresentable:
            content = configuration.makeContent()
        case let configuration as any OptionalFloatingPointFlagTextFieldRepresentable:
            content = configuration.makeContent()
        case let configuration as any StringFlagTextFieldRepresentable:
            content = configuration.makeContent()
        case let configuration as any OptionalStringFlagTextFieldRepresentable:
            content = configuration.makeContent()
        default:
            content = Text("Unimplemented \(configuration.name)").frame(maxWidth: .infinity)
        }
    }
    
    var body: some View {
        AnyView(content)
    }
    
}
