// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "AppRouter",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "AppRouter-AppExtensionAPI",
            targets: ["AppRouter-AppExtensionAPI"]
        ),
        .library(
            name: "AppRouter-Core",
            targets: ["AppRouter-Core"]
        ),
        .library(
            name: "AppRouter-Route",
            targets: ["AppRouter-Route"]
        ),
        .library(
            name: "AppRouter-RxSwift",
            targets: ["AppRouter-RxSwift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/sinarionn/ReusableView.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "AppRouter-AppExtensionAPI",
            path: "Sources/AppExtensionAPI"
        ),
        .target(
            name: "AppRouter-Core",
            dependencies: ["AppRouter-AppExtensionAPI"],
            path: "Sources/Core"
        ),
        .target(
            name: "AppRouter-Route",
            dependencies: [
                "AppRouter-Core",
                "RxSwift",
                "ReusableView"
            ],
            path: "Sources/Route"
        ),
        .target(
            name: "AppRouter-RxSwift",
            dependencies: [
                "RxSwift"
            ],
            path: "Sources/RxSwift"
        )
    ]
)
