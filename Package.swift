// swift-tools-version:5.2
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
        .library(name: "Vexil", targets: [ "Vexil" ]),
        .library(name: "Vexilographer", targets: [ "Vexilographer" ]),
    ],

    dependencies: [
    ],

    targets: [
        .target(name: "Vexil", dependencies: []),
        .testTarget(name: "VexilTests", dependencies: [ "Vexil" ]),

        .target(name: "Vexilographer", dependencies: [ "Vexil" ]),
        .testTarget(name: "VexilographerTests", dependencies: [ "Vexilographer" ])
    ]
)
