# ``Vexillographer``

How why and where to use Vexillographer, Vexil's SwiftUI-based flag editing UI

## Overview

The second library product of Vexil is Vexillographer, a small SwiftUI tool for displaying and manipulating flags.

![Screenshots](screenshots.png)

## Usage

You include it in your project somewhere and initialise it with a `FlagPole` and `FlagValueSource`:

```swift
import Vexillographer

struct MyView: View {

    let flagPole = FlagPole(hoist: AppFlags.swift)
    
    var body: some View {
        NavigationView {
            Form {
                Vexillographer(flagPole: flagPole, source: UserDefaults.standard)
            }
        }
    }
    
}
```

Vexillographer will then display a that lists all of your `Flag`s and `FlagGroup`s, allowing you to drill down your configured flags and edit their values directly.

## Where to put Vexillographer

While you can include Vexillographer in your app hidden behind some secret gesture or conditional compilation or feature flag technique (mind that inception), we strongly recommend you don't do this.

Instead, create a separate app and using [App Groups][app-groups] setup [shared user defaults][shared-userdefaults] between it and your app. You can use that shared `UserDefaults` as your main `FlagValueSource`, or you can include multiple ones to keep local overrides separate.

## Topics

### Beautiful Flag Editing

- ``Vexillographer/Vexillographer``

[app-groups]: https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups
[shared-userdefaults]: https://medium.com/ios-os-x-development/shared-user-defaults-in-ios-3f15cd2c9409
