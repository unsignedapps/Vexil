// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Vexil",

    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],

    products: [
        // Automatic
        .library(name: "Vexil", targets: [ "Vexil" ]),
//        .library(name: "Vexillographer", targets: [ "Vexillographer" ]),
    ],

    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.51.2"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
    ],

    targets: [
        .target(
            name: "Vexil",
            dependencies: [
                //                .target(name: "VexilMacros"),
            ]
        ),
        .testTarget(name: "VexilTests", dependencies: [ "Vexil" ]),

//        .macro(
//            name: "VexilMacros",
//            dependencies: [
//                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
//                .product(name: "SwiftSyntax", package: "swift-syntax"),
//                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
//                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
//            ]
//        ),
//        .testTarget(
//            name: "VexilMacroTests",
//            dependencies: [
//                .target(name: "VexilMacros"),
//                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
//            ]
//        ),
//
//        .target(name: "Vexillographer", dependencies: [ "Vexil" ]),
    ],

    swiftLanguageVersions: [
        .v5,
    ]
)
