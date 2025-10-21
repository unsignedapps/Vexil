import SwiftUI
import Vexil

public protocol FlagControlStyle<Value>: DynamicProperty {

    associatedtype Value: FlagValue
    associatedtype Body: View

    typealias Configuration = FlagControlConfiguration

    @ViewBuilder @MainActor func makeBody(configuration: Configuration<Value>) -> Body

}

public extension View {

    func flagControlStyle<Style: FlagControlStyle>(_ style: Style) -> some View {
        modifier(FlagControlStyleModifier(style: style, key: ObjectIdentifier(Style.Value.self)))
    }

    func flagControlStyle<Style: FlagControlStyle>(_ style: Style, for keyPath: KeyPath<some FlagContainer, Style.Value>) -> some View {
        modifier(FlagControlStyleModifier(style: style, key: keyPath))
    }

}

private struct FlagControlStyleModifier<Style: FlagControlStyle>: ViewModifier {

    var style: Style
    var key: AnyHashable

    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.flagPoleContext) {
                $0.styles[key] = style
            }
    }

}

extension FlagControlStyle {

    @MainActor
    func control(configuration: Configuration<some FlagValue>) -> AnyView? {
        (configuration as? Configuration<Value>).map { AnyView(StyledFlagControl(configuration: $0, style: self)) }
    }

}
