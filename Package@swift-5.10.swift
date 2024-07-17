// swift-tools-version:5.10
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
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
        .package(url: "https://github.com/apple/swift-testing.git", exact: "0.7.0"),
    ],

    targets: .init {

        // Vexil

        Target.target(
            name: "Vexil",
            dependencies: [
                .target(name: "VexilMacros"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        )
        Target.testTarget(
            name: "VexilTests",
            dependencies: [
                .target(name: "Vexil"),
                .product(name: "Testing", package: "swift-testing"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .define("SWT_TARGET_OS_APPLE", .when(platforms: [.macOS, .iOS, .macCatalyst, .watchOS, .tvOS, .visionOS])),
                .define("SWT_NO_FILE_IO", .when(platforms: [.wasi])),
            ]
        )

        // Vexillographer

        //        Target.target(
        //            name: "Vexillographer",
        //            dependencies: [
        //                .target(name: "Vexil"),
        //            ]
        //        ),

        // Macros

        Target.macro(
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
        )

#if !os(Linux)

        // We can't disable macro validation using `swift test` so these are guaranteed to fail on Linux
        Target.testTarget(
            name: "VexilMacroTests",
            dependencies: [
                .target(name: "VexilMacros"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        )

#endif

    },

    swiftLanguageVersions: [
        .v5,
    ]
)

// MARK: - Helpers

@resultBuilder
enum CollectionBuilder<Element> {

    typealias Component = [Element]

    static func buildExpression(_ expression: Element) -> Component {
        [expression]
    }

    static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }

    static func buildLimitedAvailability(_ components: [Element]) -> Component {
        components
    }

}

extension Array {
    init(@CollectionBuilder<Element> collecting: () -> [Element]) {
        self = collecting()
    }
}
