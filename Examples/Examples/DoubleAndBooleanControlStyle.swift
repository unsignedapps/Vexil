import SwiftUI
import Vexillographer

struct DoubleAndBooleanControlStyle: FlagControlStyle {

    func makeBody(configuration: Configuration<CustomFlags.DoubleAndBoolean>) -> some View {
        VStack {
            Toggle(configuration.name, isOn: configuration.$value.isEnabled)
            Slider(value: configuration.$value.percent, in: 0...1.0) {
                Text("Percent \(configuration.value.percent)")
            } minimumValueLabel: {
                Text("0.0")
            } maximumValueLabel: {
                Text("1.0")
            }
            .disabled(!configuration.value.isEnabled)
        }
    }

}

extension FlagControlStyle where Self == DoubleAndBooleanControlStyle {

    static var doubleAndBoolean: Self { Self() }

}
