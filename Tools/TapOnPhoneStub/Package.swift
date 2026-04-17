// swift-tools-version:5.9
//
//  Package.swift
//
//  CI-only stub of the proprietary Getnet TapOnPhone SDK. Exposes the
//  same public symbols documented in the SDK PDF so the sample app
//  type-checks and links in GitHub Actions without distributing the
//  real framework.
//
//  DO NOT ship this package — use the real `TapOnPhone.xcframework`
//  from Getnet for anything other than CI compilation.
//

import PackageDescription

let package = Package(
    name: "TapOnPhoneStub",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TapOnPhone",
            targets: ["TapOnPhone"]
        )
    ],
    targets: [
        .target(
            name: "TapOnPhone",
            path: "Sources/TapOnPhone"
        )
    ]
)
