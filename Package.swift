// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "AppRouter",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "AppRouterExtensionAPI",
            targets: ["AppRouterExtensionAPI"]
        ),
        .library(
            name: "AppRouterCore",
            targets: ["AppRouterCore"]
        ),
        .library(
            name: "AppRouterRoute",
            targets: ["AppRouterRoute"]
        ),
        .library(
            name: "AppRouterRxSwift",
            targets: ["AppRouterRxSwift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/sinarionn/ReusableView.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "AppRouterExtensionAPI",
            path: "Sources/AppExtensionAPI"
        ),
        .target(
            name: "AppRouterCore",
            dependencies: ["AppRouterExtensionAPI"],
            path: "Sources/Core"
        ),
        .target(
            name: "AppRouterRoute",
            dependencies: [
                "AppRouterCore",
                "ReusableView",
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift"),
            ],
            path: "Sources/Route"
        ),
        .target(
            name: "AppRouterRxSwift",
            dependencies: [
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "Sources/RxSwift"
        )
    ]
)
