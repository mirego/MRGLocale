// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MRGLocale",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "MRGLocale",
            targets: ["MRGLocale", "MRGLocaleSwift"]
        ),
        .library(
            name: "MRGLocaleControlPanel",
            targets: ["MRGLocaleControlPanel"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mirego/MRGControlPanel.git", from: "0.1.2"),
    ],
    targets: [
        .target(
            name: "MRGLocale",
            path: "Sources/MRGLocale",
            publicHeadersPath: "."
        ),
        .target(
            name: "MRGLocaleSwift",
            dependencies: ["MRGLocale"],
            path: "Sources/MRGLocaleSwift"
        ),
        .target(
            name: "MRGLocaleControlPanel",
            dependencies: [
                "MRGLocale",
                .product(name: "MRGControlPanel", package: "MRGControlPanel"),
            ],
            path: "Sources/MRGLocaleControlPanel",
            publicHeadersPath: "."
        ),
    ]
)
