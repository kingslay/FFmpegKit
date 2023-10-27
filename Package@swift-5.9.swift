// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FFmpegKit",
    defaultLocalization: "en",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13),
                .visionOS(.v1)],
    products: [
        .library(
            name: "FFmpegKit",
//            type: .static,
            targets: ["FFmpegKit"]
        ),
        .library(name: "Libavcodec", targets: ["Libavcodec"]),
        .library(name: "Libavfilter", targets: ["Libavfilter"]),
        .library(name: "Libavformat", targets: ["Libavformat"]),
        .library(name: "Libavutil", targets: ["Libavutil"]),
        .library(name: "Libswresample", targets: ["Libswresample"]),
        .library(name: "Libswscale", targets: ["Libswscale"]),
        .library(name: "Libssl", targets: ["Libssl"]),
        .library(name: "Libcrypto", targets: ["Libcrypto"]),
//        .library(name: "Libass", targets: ["Libpng", "Libfreetype", "Libfribidi", "Libharfbuzz", "Libass"]),
//        .library(name: "Libmpv", targets: ["FFmpegKit", "Libass", "Libmpv"]),
        .executable(name: "ffplay", targets: ["ffplay"]),
        .executable(name: "ffmpeg", targets: ["ffmpeg"]),
        .executable(name: "ffprobe", targets: ["ffprobe"]),
        .plugin(name: "BuildFFmpeg", targets: ["BuildFFmpeg"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "FFmpegKit",
            dependencies: [
                "Libavcodec", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "Libssl", "Libcrypto",
                "Libdav1d",
                "Libsrt",
                "Libzvbi",
            ],
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Metal"),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("bz2"),
                .linkedLibrary("iconv"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
                .linkedLibrary("c++"),
            ]
        ),
        .executableTarget(
            name: "ffplay",
            dependencies: [
                "fftools",
                "SDL2",
            ]
        ),
        .executableTarget(
            name: "ffprobe",
            dependencies: [
                "fftools",
            ]
        ),
        .executableTarget(
            name: "ffmpeg",
            dependencies: [
                "fftools",
            ]
        ),
        .target(
            name: "fftools",
            dependencies: [
                "FFmpegKit",
            ]
        ),
        .systemLibrary(
            name: "SDL2",
            pkgConfig: "sdl2",
            providers: [
                .brew(["sdl2"]),
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
            name: "BuildFFmpeg",
            capability: .command(
                intent: .custom(
                    verb: "BuildFFmpeg",
                    description: "You can customize FFmpeg and then compile FFmpeg"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command compile FFmpeg and generate xcframework. compile FFmpeg need brew install nasm sdl2 cmake. So you need add --allow-writing-to-directory /usr/local/ --allow-writing-to-directory ~/Library/ or add --disable-sandbox"),
                    .allowNetworkConnections(scope: .all(), reason: "The plugin must connect to a remote server to brew install nasm sdl2 cmake"),
                ]
            )
        ),
        .binaryTarget(
            name: "Libavcodec",
            path: "Sources/Libavcodec.xcframework"
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
            name: "Libssl",
            path: "Sources/Libssl.xcframework"
        ),
        .binaryTarget(
            name: "Libcrypto",
            path: "Sources/Libcrypto.xcframework"
        ),
        .binaryTarget(
            name: "Libdav1d",
            path: "Sources/Libdav1d.xcframework"
        ),
        .binaryTarget(
            name: "Libsrt",
            path: "Sources/Libsrt.xcframework"
        ),
        .binaryTarget(
            name: "Libzvbi",
            path: "Sources/Libzvbi.xcframework"
        ),
//        .binaryTarget(
//            name: "Libass",
//            path: "Sources/Libass.xcframework"
//        ),
//        .binaryTarget(
//            name: "Libpng",
//            path: "Sources/Libpng.xcframework"
//        ),
//        .binaryTarget(
//            name: "Libfreetype",
//            path: "Sources/Libfreetype.xcframework"
//        ),
//        .binaryTarget(
//            name: "Libfribidi",
//            path: "Sources/Libfribidi.xcframework"
//        ),
//        .binaryTarget(
//            name: "Libharfbuzz",
//            path: "Sources/Libharfbuzz.xcframework"
//        ),
//        .binaryTarget(
//            name: "Libmpv",
//            path: "Sources/Libmpv.xcframework"
//        ),
    ]
)
