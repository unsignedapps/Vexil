import SwiftUI
import Vexillographer
import Vexil

struct RootView: View {
    var body: some View {
        NavigationView {
            Vexillographer()
                .flagPole(
                    Dependencies.current.flags,
                    editableSource: Dependencies.current.flags._sources.first
                )
        }
        .task {
            do {
                for value in 0... {
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                    try RemoteFlags.values.setFlagValue(value, key: "number")
                }
            } catch { }
        }
    }
}

#Preview {
    RootView()
}
