// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Vexil",

    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],

    products: [
        // Automatic
        .library(name: "Vexil", targets: [ "Vexil" ]),
//        .library(name: "Vexillographer", targets: [ "Vexillographer" ]),
    ],

    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.54.1"),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "600.0.0-prerelease-2024-06-12"),
    ],

    targets: {
        var targets: [Target] = [

            // Vexil

            .target(
                name: "Vexil",
                dependencies: [
                    .target(name: "VexilMacros"),
                    .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                ],
                swiftSettings: [
                    .enableExperimentalFeature("StrictConcurrency"),
                ]
            ),
            .testTarget(
                name: "VexilTests",
                dependencies: [
                    .target(name: "Vexil"),
                ],
                swiftSettings: [
                    .enableExperimentalFeature("StrictConcurrency"),
                ]
            ),

            // Vexillographer

//            .target(
//                name: "Vexillographer",
//                dependencies: [
//                    .target(name: "Vexil"),
//                ]
//            ),

            // Macros

            .macro(
                name: "VexilMacros",
                dependencies: [
                    .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                ],
                swiftSettings: [
                    .enableExperimentalFeature("StrictConcurrency"),
                ]
            ),

        ]

#if !os(Linux)
        targets += [
            .testTarget(
                name: "VexilMacroTests",
                dependencies: [
                    .target(name: "VexilMacros"),
                    .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                ],
                swiftSettings: [
                    .enableExperimentalFeature("StrictConcurrency"),
                ]
            ),
        ]
#endif

        return targets
    }(),

    swiftLanguageVersions: [
        .v6,
    ]
)
