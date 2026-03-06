// swift-tools-version:5.9
import Foundation
import PackageDescription

func prefixedPath(_ name: String) -> String {
    let prefixed = "Sources/\(name).xcframework"
    if FileManager.default.fileExists(atPath: prefixed) {
        return prefixed
    }
    if name.hasPrefix("KSPFF") {
        let fallback = String(name.dropFirst("KSPFF".count))
        return "Sources/\(fallback).xcframework"
    }
    return prefixed
}

let package = Package(
    name: "FFmpegKit",
    defaultLocalization: "en",
    platforms: [.macOS(.v10_15), .macCatalyst(.v14), .iOS(.v13), .tvOS(.v13),
                .visionOS(.v1)],
    products: [
        .library(
            name: "FFmpegKit",
//            type: .static,
            targets: ["FFmpegKit"]
        ),
        .library(name: "KSPFFLibavcodec", targets: ["KSPFFLibavcodec"]),
        .library(name: "KSPFFLibavfilter", targets: ["KSPFFLibavfilter"]),
        .library(name: "KSPFFLibavformat", targets: ["KSPFFLibavformat"]),
        .library(name: "KSPFFLibavutil", targets: ["KSPFFLibavutil"]),
        .library(name: "KSPFFLibswresample", targets: ["KSPFFLibswresample"]),
        .library(name: "KSPFFLibswscale", targets: ["KSPFFLibswscale"]),
        .library(name: "KSPFFlibass", targets: ["KSPFFlibfreetype", "KSPFFlibfribidi", "KSPFFlibharfbuzz", "KSPFFlibass"]),
        .library(name: "KSPFFlibmpv", targets: ["FFmpegKit", "KSPFFlibass", "KSPFFlibmpv"]),
        .plugin(name: "BuildFFmpeg", targets: ["BuildFFmpeg"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "FFmpegKit",
            dependencies: [
                "KSPFFMoltenVK",
                "KSPFFlibshaderc_combined",
                "KSPFFlcms2",
                "KSPFFlibdav1d",
                "KSPFFlibplacebo",
                .target(name: "KSPFFlibzvbi", condition: .when(platforms: [.macOS, .iOS, .tvOS, .visionOS])),
                "KSPFFlibsrt",
                "KSPFFlibfreetype", "KSPFFlibfribidi", "KSPFFlibharfbuzz", "KSPFFlibass",
                "KSPFFlibfontconfig",
                .target(name: "KSPFFlibbluray", condition: .when(platforms: [.macOS])),
                "KSPFFgmp", "KSPFFnettle", "KSPFFhogweed", "KSPFFgnutls",
                "KSPFFlibsmbclient",
                "KSPFFLibavcodec", "KSPFFLibavdevice", "KSPFFLibavfilter", "KSPFFLibavformat", "KSPFFLibavutil", "KSPFFLibswresample", "KSPFFLibswscale",
            ],
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("AVFAudio"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Cocoa", .when(platforms: [.macOS])),
                .linkedFramework("DiskArbitration", .when(platforms: [.macOS])),
                .linkedFramework("Foundation"),
                .linkedFramework("Metal"),
                .linkedFramework("IOKit", .when(platforms: [.macOS, .iOS, .visionOS, .macCatalyst])),
                .linkedFramework("IOSurface"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("Security"),
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS, .visionOS, .macCatalyst])),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("bz2"),
                .linkedLibrary("c++"),
                .linkedLibrary("expat", .when(platforms: [.macOS])),
                .linkedLibrary("iconv"),
                .linkedLibrary("resolv"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
            ]
        ),
//        .target(
//            name: "libavutil",
//            cSettings: [.headerSearchPath("../")]
//        ),
//        .executableTarget(
//            name: "BuildFFmpegPlugin",
//            path: "Plugins/BuildFFmpeg"
//        ),
        .plugin(
            name: "BuildFFmpeg", capability: .command(
                intent: .custom(
                    verb: "BuildFFmpeg",
                    description: "You can customize FFmpeg and then compile FFmpeg"
                ),
                permissions: [
                    //                    .writeToPackageDirectory(reason: "This command compile FFmpeg and generate xcframework. compile FFmpeg need brew install nasm sdl2 cmake. So you need add --allow-writing-to-directory /usr/local/ --allow-writing-to-directory ~/Library/ or add --disable-sandbox"),
//                    .allowNetworkConnections(scope: .all(), reason: "The plugin must connect to a remote server to brew install nasm sdl2 cmake"),
                ]
            )
        ),
        .binaryTarget(
            name: "KSPFFMoltenVK",
            path: prefixedPath("KSPFFMoltenVK")
        ),
        .binaryTarget(
            name: "KSPFFlibshaderc_combined",
            path: prefixedPath("KSPFFlibshaderc_combined")
        ),

        .binaryTarget(
            name: "KSPFFlcms2",
            path: prefixedPath("KSPFFlcms2")
        ),
        .binaryTarget(
            name: "KSPFFlibplacebo",
            path: prefixedPath("KSPFFlibplacebo")
        ),
        .binaryTarget(
            name: "KSPFFlibdav1d",
            path: prefixedPath("KSPFFlibdav1d")
        ),
        .binaryTarget(
            name: "KSPFFLibavcodec",
            path: prefixedPath("KSPFFLibavcodec")
        ),
        .binaryTarget(
            name: "KSPFFLibavdevice",
            path: prefixedPath("KSPFFLibavdevice")
        ),
        .binaryTarget(
            name: "KSPFFLibavfilter",
            path: prefixedPath("KSPFFLibavfilter")
        ),
        .binaryTarget(
            name: "KSPFFLibavformat",
            path: prefixedPath("KSPFFLibavformat")
        ),
        .binaryTarget(
            name: "KSPFFLibavutil",
            path: prefixedPath("KSPFFLibavutil")
        ),
        .binaryTarget(
            name: "KSPFFLibswresample",
            path: prefixedPath("KSPFFLibswresample")
        ),
        .binaryTarget(
            name: "KSPFFLibswscale",
            path: prefixedPath("KSPFFLibswscale")
        ),
        .binaryTarget(
            name: "KSPFFlibsrt",
            path: prefixedPath("KSPFFlibsrt")
        ),
        .binaryTarget(
            name: "KSPFFlibzvbi",
            path: prefixedPath("KSPFFlibzvbi")
        ),
        .binaryTarget(
            name: "KSPFFlibfreetype",
            path: prefixedPath("KSPFFlibfreetype")
        ),
        .binaryTarget(
            name: "KSPFFlibfribidi",
            path: prefixedPath("KSPFFlibfribidi")
        ),
        .binaryTarget(
            name: "KSPFFlibharfbuzz",
            path: prefixedPath("KSPFFlibharfbuzz")
        ),
        .binaryTarget(
            name: "KSPFFlibass",
            path: prefixedPath("KSPFFlibass")
        ),
        .binaryTarget(
            name: "KSPFFlibmpv",
            path: prefixedPath("KSPFFlibmpv")
        ),
        .binaryTarget(
            name: "KSPFFgmp",
            path: prefixedPath("KSPFFgmp")
        ),
        .binaryTarget(
            name: "KSPFFnettle",
            path: prefixedPath("KSPFFnettle")
        ),
        .binaryTarget(
            name: "KSPFFhogweed",
            path: prefixedPath("KSPFFhogweed")
        ),
        .binaryTarget(
            name: "KSPFFlibfontconfig",
            path: prefixedPath("KSPFFlibfontconfig")
        ),
        .binaryTarget(
            name: "KSPFFlibbluray",
            path: prefixedPath("KSPFFlibbluray")
        ),
        .binaryTarget(
            name: "KSPFFgnutls",
            path: prefixedPath("KSPFFgnutls")
        ),
        .binaryTarget(
            name: "KSPFFlibsmbclient",
            path: prefixedPath("KSPFFlibsmbclient")
        ),
//        .binaryTarget(
//            name: "libssl",
//            path: "Sources/libssl.xcframework"
//        ),
//        .binaryTarget(
//            name: "libcrypto",
//            path: "Sources/libcrypto.xcframework"
//        ),
    ]
)
