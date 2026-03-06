// swift-tools-version:5.9
import PackageDescription

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
            path: "Sources/MoltenVK.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibshaderc_combined",
            path: "Sources/libshaderc_combined.xcframework"
        ),

        .binaryTarget(
            name: "KSPFFlcms2",
            path: "Sources/lcms2.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibplacebo",
            path: "Sources/libplacebo.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibdav1d",
            path: "Sources/libdav1d.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFLibavcodec",
            path: "Sources/Libavcodec.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFLibavdevice",
            path: "Sources/Libavdevice.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFLibavfilter",
            path: "Sources/Libavfilter.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFLibavformat",
            path: "Sources/Libavformat.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFLibavutil",
            path: "Sources/Libavutil.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFLibswresample",
            path: "Sources/Libswresample.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFLibswscale",
            path: "Sources/Libswscale.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibsrt",
            path: "Sources/libsrt.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibzvbi",
            path: "Sources/libzvbi.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibfreetype",
            path: "Sources/libfreetype.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibfribidi",
            path: "Sources/libfribidi.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibharfbuzz",
            path: "Sources/libharfbuzz.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibass",
            path: "Sources/libass.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibmpv",
            path: "Sources/libmpv.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFgmp",
            path: "Sources/gmp.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFnettle",
            path: "Sources/nettle.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFhogweed",
            path: "Sources/hogweed.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibfontconfig",
            path: "Sources/libfontconfig.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibbluray",
            path: "Sources/libbluray.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFgnutls",
            path: "Sources/gnutls.xcframework"
        ),
        .binaryTarget(
            name: "KSPFFlibsmbclient",
            path: "Sources/libsmbclient.xcframework"
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
