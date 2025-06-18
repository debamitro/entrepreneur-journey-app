// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ejourney",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/clerk/clerk-ios", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "ejourney",
            dependencies: [
                .product(name: "Clerk", package: "clerk-ios")
            ]
        )
    ]
)
