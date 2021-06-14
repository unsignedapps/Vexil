// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Vexil",
    
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],

    products: [
        // Automatic
        .library(name: "Vexil", targets: [ "Vexil" ]),
        .library(name: "Vexillographer", targets: [ "Vexillographer" ]),
    ],

    dependencies: [
    ],

    targets: [
        .target(name: "Vexil", dependencies: []),
        .testTarget(name: "VexilTests", dependencies: [ "Vexil" ]),

        .target(name: "Vexillographer", dependencies: [ "Vexil" ]),
    ],

    swiftLanguageVersions: [
        .v5
    ]
)
