// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "RAML",
    dependencies: [
        .Package(url: "https://github.com/behrang/YamlSwift.git", majorVersion: 3, minor: 4),
        .Package(url: "https://github.com/kylef/PathKit.git", majorVersion: 0, minor: 8)
    ]
)
