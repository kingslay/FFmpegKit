// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "FFmpegKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .macCatalyst(.v14), .macOS(.v10_15), .tvOS(.v13), .visionOS(.v1), .watchOS(.v6)],
    products: [
        .library(
            name: "FFmpegKit",
//            type: .dynamic,
            targets: [
                "FFmpegKit",
                // 支持spm打包成framework
                "lcms2", "libdav1d", "libsrt", "libfreetype", "libfribidi", "libharfbuzz", "libass", "libfontconfig", "libopus",
                "libssl", "libcrypto",
                // 这三个库不支持watchOS
                //                "libdovi", "libplacebo", "MoltenVK",
                //                "gmp", "nettle", "hogweed", "gnutls",
            ]
        ),
        .library(name: "Libavcodec", targets: ["Libavcodec"]),
        .library(name: "Libavfilter", targets: ["Libavfilter"]),
        .library(name: "Libavformat", targets: ["Libavformat"]),
        .library(name: "Libavutil", targets: ["Libavutil"]),
        .library(name: "Libswresample", targets: ["Libswresample"]),
        .library(name: "Libswscale", targets: ["Libswscale"]),
        .library(name: "libass", targets: ["libfreetype", "libfribidi", "libharfbuzz", "libfontconfig", "libass"]),
        .library(name: "libmpv", targets: ["FFmpegKit", "libass", "libmpv"]),
        .library(name: "libzvbi", targets: ["libzvbi"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "FFmpegKit",
            dependencies: [
                "Libavcodec", "Libavdevice", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "lcms2", "libass", "libdav1d", "libharfbuzz", "libfontconfig", "libfreetype", "libfribidi", "libopus", "libsrt", "libzvbi",
                "libcrypto", "libssl",
//                "gmp", "nettle", "hogweed", "gnutls",
                .targetItem(name: "libdovi", condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS, .visionOS])),
                .targetItem(name: "libplacebo", condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS, .visionOS])),
                .targetItem(name: "MoltenVK", condition: .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS, .visionOS])),
            ],
            resources: [.process("Resources")],
            cSettings: [
                .headerSearchPath("private"),
            ],
            linkerSettings: [
                .linkedFramework("AudioToolbox", .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS, .visionOS])),
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
                .linkedFramework("Metal", .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS, .visionOS])),
                .linkedFramework("IOKit", .when(platforms: [.iOS, .macCatalyst, .macOS, .visionOS])),
                .linkedFramework("IOSurface", .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS, .visionOS])),
                .linkedFramework("QuartzCore"),
                .linkedFramework("Security"),
                .linkedFramework("UIKit", .when(platforms: [.iOS, .macCatalyst, .tvOS, .visionOS, .watchOS])),
                .linkedFramework("VideoToolbox", .when(platforms: [.iOS, .macCatalyst, .macOS, .tvOS, .visionOS])),
                .linkedLibrary("bz2"),
                .linkedLibrary("c++"),
                // freetype 需要用到expat，所以全平台都要引入expat。iOS13 dyld: Library not loaded: /usr/lib/libexpat.1.dylib。所以计划iOS13就不支持了
                .linkedLibrary("expat"),
                .linkedLibrary("iconv"),
                .linkedLibrary("resolv"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
            ]
        ),
        .binaryTarget(
            name: "MoltenVK",
            path: "Sources/MoltenVK.xcframework"
        ),

        .binaryTarget(
            name: "lcms2",
            path: "Sources/lcms2.xcframework"
        ),
        .binaryTarget(
            name: "libplacebo",
            path: "Sources/libplacebo.xcframework"
        ),
        .binaryTarget(
            name: "libdav1d",
            path: "Sources/libdav1d.xcframework"
        ),
        .binaryTarget(
            name: "libdovi",
            path: "Sources/libdovi.xcframework"
        ),
        .binaryTarget(
            name: "Libavcodec",
            path: "Sources/Libavcodec.xcframework"
        ),
        .binaryTarget(
            name: "Libavdevice",
            path: "Sources/Libavdevice.xcframework"
        ),
        .binaryTarget(
            name: "Libavfilter",
            path: "Sources/Libavfilter.xcframework"
        ),
        .binaryTarget(
            name: "Libavformat",
            path: "Sources/Libavformat.xcframework"
        ),
        .binaryTarget(
            name: "Libavutil",
            path: "Sources/Libavutil.xcframework"
        ),
        .binaryTarget(
            name: "Libswresample",
            path: "Sources/Libswresample.xcframework"
        ),
        .binaryTarget(
            name: "Libswscale",
            path: "Sources/Libswscale.xcframework"
        ),
        .binaryTarget(
            name: "libsrt",
            path: "Sources/libsrt.xcframework"
        ),
        .binaryTarget(
            name: "libzvbi",
            path: "Sources/libzvbi.xcframework"
        ),
        .binaryTarget(
            name: "libfreetype",
            path: "Sources/libfreetype.xcframework"
        ),
        .binaryTarget(
            name: "libfribidi",
            path: "Sources/libfribidi.xcframework"
        ),
        .binaryTarget(
            name: "libharfbuzz",
            path: "Sources/libharfbuzz.xcframework"
        ),
        .binaryTarget(
            name: "libass",
            path: "Sources/libass.xcframework"
        ),
        .binaryTarget(
            name: "libmpv",
            path: "Sources/libmpv.xcframework"
        ),
        .binaryTarget(
            name: "libopus",
            path: "Sources/libopus.xcframework"
        ),
        .binaryTarget(
            name: "libfontconfig",
            path: "Sources/libfontconfig.xcframework"
        ),
        .binaryTarget(
            name: "libssl",
            path: "Sources/libssl.xcframework"
        ),
        .binaryTarget(
            name: "libcrypto",
            path: "Sources/libcrypto.xcframework"
        ),
    ],
    swiftLanguageModes: [
        .v5,
        .v6,
    ],
    cLanguageStandard: .c11
)
