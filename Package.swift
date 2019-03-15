// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "satokoda",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
	.package(url: "https://github.com/chicio/ID3TagEditor.git", from: "2.2.0"),
	.package(url: "https://github.com/objecthub/swift-commandlinekit.git", from: "0.2.5"),
    .package(url: "https://github.com/dduan/TOMLDecoder", from: "0.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "satokoda",
            dependencies: ["ID3TagEditor", "CommandLineKit", "TOMLDecoder"]),
        .testTarget(
            name: "satokodaTests",
            dependencies: ["satokoda"]),
    ]
)
