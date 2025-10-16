import SwiftUI

struct RowContent<Content: View>: View {

    var label: String
    var content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    init(_ label: String, value: some Any) where Content == Text {
        self.label = label
        self.content = Text(String(describing: value))
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
            Spacer()
            content
                .foregroundStyle(.secondary)
        }
    }

}
