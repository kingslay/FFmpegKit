import Foundation
@main struct Build {}

#if canImport(PackagePlugin)
import PackagePlugin
extension Build: CommandPlugin {
    func performCommand(context _: PluginContext, arguments: [String]) throws {
        try Build.performCommand(arguments: arguments)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
extension Build: XcodeCommandPlugin {
    func performCommand(context _: XcodePluginContext, arguments: [String]) throws {
        try Build.performCommand(arguments: arguments)
    }
}
#endif

#else
extension Build {
    static func main() throws {
        try performCommand(arguments: Array(CommandLine.arguments.dropFirst()))
    }
}
#endif

extension Build {
    static var ffmpegConfiguers = [String]()
    static func performCommand(arguments: [String]) throws {
        print(arguments)
        if arguments.contains("h") || arguments.contains("-h") || arguments.contains("--help") {
            printHelp()
            return
        }
        if Utility.shell("which brew") == nil {
            print("""
            You need to run the script first
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            """)
            return
        }
        if Utility.shell("which pkg-config") == nil {
            Utility.shell("brew install pkg-config")
        }
        let path = URL.currentDirectory + ".Script"
        if !FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        }
        FileManager.default.changeCurrentDirectoryPath(path.path)
        var librarys = [Library]()
        var isFFmpegDebug = false
        for argument in arguments {
            if argument == "enable-debug" {
                isFFmpegDebug = true
            } else if argument.hasPrefix("platforms=") {
                let values = String(argument.suffix(argument.count - "platforms=".count))
                let platforms = values.split(separator: ",").compactMap {
                    PlatformType(rawValue: String($0))
                }
                if !platforms.isEmpty {
                    BaseBuild.platforms = platforms
                }
            } else if argument.hasPrefix("enable-") {
                let value = String(argument.suffix(argument.count - "enable-".count))
                if let library = Library(rawValue: value) {
                    librarys.append(library)
                }
            } else if argument.hasPrefix("--"), argument != "--disable-sandbox", argument != "--allow-writing-to-directory" {
                Build.ffmpegConfiguers.append(argument)
            }
        }
        if isFFmpegDebug {
            Build.ffmpegConfiguers.append("--enable-debug")
            Build.ffmpegConfiguers.append("--disable-stripping")
            Build.ffmpegConfiguers.append("--disable-optimizations")
        } else {
            Build.ffmpegConfiguers.append("--disable-debug")
            Build.ffmpegConfiguers.append("--enable-stripping")
            Build.ffmpegConfiguers.append("--enable-optimizations")
        }
        if arguments.isEmpty {
            librarys.append(contentsOf: [.libdav1d, .openssl, .libsrt, .FFmpeg])
        } else if arguments == ["mpv"] {
            librarys.append(contentsOf: [.libdav1d, .openssl, .libsrt, .png, .libfreetype, .libfribidi, .harfbuzz, .libass, .FFmpeg, .mpv])
        }
        for library in librarys {
            try library.build.buildALL()
        }
    }

    static func printHelp() {
        print("""
        Usage: swift package BuildFFmpeg [OPTION]...
        Default Build: swift package --disable-sandbox BuildFFmpeg enable-libdav1d enable-openssl enable-libsrt enable-FFmpeg
        Build MPV: swift package --disable-sandbox BuildFFmpeg mpv or swift package --disable-sandbox BuildFFmpeg enable-libdav1d enable-openssl enable-libsrt enable-png enable-libfreetype enable-libfribidi enable-harfbuzz enable-libass enable-FFmpeg enable-mpv
        Options:
            h, -h, --help       display this help and exit
            enable-debug,       build ffmpeg with debug information
            platforms=xros      deployment platform: ios,isimulator,tvos,tvsimulator,macos,maccatalyst,xros,xrsimulator,watchos,watchsimulator,
            --xx                add ffmpeg Configuers
            mpv                 build mpv

        Libraries:
            enable-libdav1d     build with dav1d
            enable-openssl      build with openssl
            enable-libsrt       depend enable-openssl
            enable-libfreetype  depend enable-png [no]
            enable-libass       depend enable-png enable-libfreetype enable-libfribidi enable-harfbuzz [no]
            enable-nettle       depend enable-gmp [no]
            enable-gnutls       depend enable-gmp enable-nettle [no]
            enable-libsmbclient depend enable-gmp enable-nettle enable-gnutls [no]
            enable-harfbuzz     depend enable-libfreetype [no]
            enable-FFmpeg       build with FFmpeg
            enable-mpv          depend enable-png enable-libfreetype enable-libfribidi enable-harfbuzz enable-libass [no]
        """)
    }
}

private enum Library: String, CaseIterable {
    case libfreetype, libfribidi, libass, openssl, libsrt, libsmbclient, gnutls, gmp, FFmpeg, nettle, harfbuzz, png, libdav1d, libtls, mpv
    var version: String {
        switch self {
        case .FFmpeg:
            return "n6.0"
        case .libfreetype:
            return "VER-2-12-1"
        case .libfribidi:
            return "v1.0.12"
        case .harfbuzz:
            return "5.3.1"
        case .libass:
            return "0.17.1-branch"
        case .png:
            return "v1.6.40"
        case .mpv:
            return "v0.36.0"
        case .openssl:
            // 用openssl-3.1.0 在真机启动会_armv8_sve_probe, 3.1.1在真机启动会crash
            return "openssl-3.1.3"
        case .libsrt:
            return "v1.5.1"
        case .libsmbclient:
            return "samba-4.18.5"
        case .gnutls:
            return "3.7.9"
        case .nettle:
            return "nettle_3.9.1_release_20230601"
        case .libdav1d:
            return "1.1.0"
        case .gmp:
            return "v6.2.1"
        case .libtls:
            return "OPENBSD_7_3"
        }
    }

    var url: String {
        switch self {
        case .png:
            return "https://github.com/glennrp/libpng"
        case .mpv:
            return "https://github.com/\(rawValue)-player/\(rawValue)"
        case .libsrt:
            return "https://github.com/Haivision/srt"
        case .libsmbclient:
            return "https://github.com/samba-team/samba"
        case .nettle:
            return "https://git.lysator.liu.se/nettle/nettle.git"
        case .gmp:
            return "https://github.com/alisw/GMP"
        case .libdav1d:
            return "https://github.com/videolan/dav1d"
        case .libtls:
            return "https://github.com/libressl/portable"
        default:
            var value = rawValue
            if self != .libass, value.hasPrefix("lib") {
                value = String(value.suffix(value.count - "lib".count))
            }
            return "https://github.com/\(value)/\(value)"
        }
    }

    var isFFmpegDependentLibrary: Bool {
        switch self {
        case .libdav1d, .openssl, .libsrt, .libsmbclient:
            return true
        case .png, .harfbuzz, .nettle, .mpv, .FFmpeg:
            return false
        default:
            return false
        }
    }

    var build: BaseBuild {
        switch self {
        case .FFmpeg:
            return BuildFFMPEG()
        case .libfreetype:
            return BuildFreetype()
        case .libfribidi:
            return BuildFribidi()
        case .harfbuzz:
            return BuildHarfbuzz()
        case .libass:
            return BuildASS()
        case .png:
            return BuildPng()
        case .mpv:
            return BuildMPV()
        case .openssl:
            return BuildOpenSSL()
        case .libsrt:
            return BuildSRT()
        case .libsmbclient:
            return BuildSmbclient()
        case .gnutls:
            return BuildGnutls()
        case .libdav1d:
            return BuildDav1d()
        case .nettle:
            return BuildNettle()
        case .gmp:
            return BuildGmp()
        case .libtls:
            return BuildLibreSSL()
        }
    }
}

private class BaseBuild {
    static var platforms = PlatformType.allCases
        .filter {
            ![.watchos, .watchsimulator].contains($0)
        }

    private let library: Library
    let directoryURL: URL
    init(library: Library) {
        self.library = library
        directoryURL = URL.currentDirectory + "\(library.rawValue)-\(library.version)"
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try! Utility.launch(path: "/usr/bin/git", arguments: ["clone", "--depth", "1", "--branch", library.version, library.url, directoryURL.path])
        }
    }

    fileprivate func buildALL() throws {
        for platform in BaseBuild.platforms {
            for arch in architectures(platform) {
                let prefix = thinDir(platform: platform, arch: arch)
                try? FileManager.default.removeItem(at: prefix)
                let buildURL = scratch(platform: platform, arch: arch)
                try? FileManager.default.removeItem(at: buildURL)
                try? FileManager.default.createDirectory(at: buildURL, withIntermediateDirectories: true, attributes: nil)
                try build(platform: platform, arch: arch, buildURL: buildURL)
            }
        }
        try createXCFramework()
    }

    private func architectures(_ platform: PlatformType) -> [ArchType] {
        platform.architectures()
    }

    func build(platform: PlatformType, arch: ArchType, buildURL: URL) throws {
        try? _ = Utility.launch(path: "/usr/bin/make", arguments: ["distclean"], currentDirectoryURL: buildURL)
        let environ = environment(platform: platform, arch: arch)
        if FileManager.default.fileExists(atPath: (directoryURL + "meson.build").path) {
            if Utility.shell("which meson") == nil {
                Utility.shell("brew install meson")
            }
            let meson = Utility.shell("which meson", isOutput: true)!
            let crossFile = createMesonCrossFile(platform: platform, arch: arch)
            try Utility.launch(path: meson, arguments: ["setup", buildURL.path, "--cross-file=\(crossFile.path)"] + arguments(platform: platform, arch: arch), currentDirectoryURL: directoryURL, environment: environ)
            try Utility.launch(path: meson, arguments: ["compile", "--clean"], currentDirectoryURL: buildURL, environment: environ)
            try Utility.launch(path: meson, arguments: ["compile", "--verbose"], currentDirectoryURL: buildURL, environment: environ)
            try Utility.launch(path: meson, arguments: ["install"], currentDirectoryURL: buildURL, environment: environ)
        } else if FileManager.default.fileExists(atPath: (directoryURL + wafPath()).path) {
            try Utility.launch(path: "/usr/bin/python3", arguments: [wafPath(), "distclean"], currentDirectoryURL: directoryURL, environment: environ)
            try Utility.launch(path: "/usr/bin/python3", arguments: [wafPath(), "configure"] + arguments(platform: platform, arch: arch), currentDirectoryURL: directoryURL, environment: environ)
            try Utility.launch(path: "/usr/bin/python3", arguments: [wafPath(), "build"], currentDirectoryURL: directoryURL, environment: environ)
            try Utility.launch(path: "/usr/bin/python3", arguments: [wafPath(), "install"], currentDirectoryURL: directoryURL, environment: environ)
        } else {
            try configure(buildURL: buildURL, environ: environ, platform: platform, arch: arch)
            try Utility.launch(path: "/usr/bin/make", arguments: ["-j5"], currentDirectoryURL: buildURL, environment: environ)
            try Utility.launch(path: "/usr/bin/make", arguments: ["-j5", "install"], currentDirectoryURL: buildURL, environment: environ)
        }
    }

    func wafPath() -> String {
        "./waf"
    }

    func configure(buildURL: URL, environ: [String: String], platform: PlatformType, arch: ArchType) throws {
        let makeLists = directoryURL + "CMakeLists.txt"
        if FileManager.default.fileExists(atPath: makeLists.path) {
            if Utility.shell("which cmake") == nil {
                Utility.shell("brew install cmake")
            }
            let cmake = Utility.shell("which cmake", isOutput: true)!
            let thinDirPath = thinDir(platform: platform, arch: arch).path
            var arguments = [
                makeLists.path,
                "-DCMAKE_VERBOSE_MAKEFILE=0",
                "-DCMAKE_BUILD_TYPE=Release",
                "-DCMAKE_OSX_SYSROOT=\(platform.sdk().lowercased())",
                "-DCMAKE_OSX_ARCHITECTURES=\(arch.rawValue)",
                "-DCMAKE_INSTALL_PREFIX=\(thinDirPath)",
                "-DBUILD_SHARED_LIBS=0",
            ]
            arguments.append(contentsOf: self.arguments(platform: platform, arch: arch))
            try Utility.launch(path: cmake, arguments: arguments, currentDirectoryURL: buildURL, environment: environ)
        } else {
            let autogen = directoryURL + "autogen.sh"
            if FileManager.default.fileExists(atPath: autogen.path) {
                var environ = environ
                environ["NOCONFIGURE"] = "1"
                try Utility.launch(executableURL: autogen, arguments: [], currentDirectoryURL: directoryURL, environment: environ)
            }
            let configure = directoryURL + "configure"
            if !FileManager.default.fileExists(atPath: configure.path) {
                var bootstrap = directoryURL + "bootstrap"
                if !FileManager.default.fileExists(atPath: bootstrap.path) {
                    bootstrap = directoryURL + ".bootstrap"
                }
                if FileManager.default.fileExists(atPath: bootstrap.path) {
                    try Utility.launch(executableURL: bootstrap, arguments: [], currentDirectoryURL: directoryURL, environment: environ)
                }
            }
            try Utility.launch(executableURL: configure, arguments: arguments(platform: platform, arch: arch), currentDirectoryURL: buildURL, environment: environ)
        }
    }

    func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        [
            "LC_CTYPE": "C",
            "CC": "/usr/bin/clang",
            "CXX": "/usr/bin/clang++",
            // "SDKROOT": platform.sdk().lowercased(),
            "CURRENT_ARCH": arch.rawValue,
            // makefile can't use CPPFLAGS
            "CPPFLAGS": platform.cFlags(arch: arch),
            "CFLAGS": platform.cFlags(arch: arch),
            "CXXFLAGS": platform.cFlags(arch: arch),
            "LDFLAGS": platform.ldFlags(arch: arch).joined(separator: " "),
            "PKG_CONFIG_PATH": platform.pkgConfigPath(arch: arch),
        ]
    }

    func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        [
            "--prefix=\(thinDir(platform: platform, arch: arch).path)",
            "--host=\(platform.host(arch: arch))",
        ]
    }

    private func createXCFramework() throws {
        var frameworks: [String] = []
        if let platform = BaseBuild.platforms.first {
            if let arch = architectures(platform).first {
                let lib = thinDir(platform: platform, arch: arch) + "lib"
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: lib.path)
                for fileName in fileNames {
                    if fileName.hasPrefix("lib"), fileName.hasSuffix(".a") {
                        frameworks.append("Lib" + fileName.dropFirst(3).dropLast(2))
                    }
                }
            }
        }
        for framework in frameworks {
            var arguments = ["-create-xcframework"]
            for platform in PlatformType.allCases {
                if let frameworkPath = try createFramework(framework: framework, platform: platform) {
                    arguments.append("-framework")
                    arguments.append(frameworkPath)
                }
            }
            arguments.append("-output")
            let XCFrameworkFile = URL.currentDirectory + ["../Sources", framework + ".xcframework"]
            arguments.append(XCFrameworkFile.path)
            if FileManager.default.fileExists(atPath: XCFrameworkFile.path) {
                try FileManager.default.removeItem(at: XCFrameworkFile)
            }
            try Utility.launch(path: "/usr/bin/xcodebuild", arguments: arguments)
        }
    }

    private func createFramework(framework: String, platform: PlatformType) throws -> String? {
        let frameworkDir = URL.currentDirectory + [library.rawValue, platform.rawValue, "\(framework).framework"]
        if !BaseBuild.platforms.contains(platform) {
            if FileManager.default.fileExists(atPath: frameworkDir.path) {
                return frameworkDir.path
            } else {
                return nil
            }
        }
        try? FileManager.default.removeItem(at: frameworkDir)
        try FileManager.default.createDirectory(at: frameworkDir, withIntermediateDirectories: true, attributes: nil)
        var arguments = ["-create"]
        for arch in architectures(platform) {
            let prefix = thinDir(platform: platform, arch: arch)
            if !FileManager.default.fileExists(atPath: prefix.path) {
                return nil
            }
            arguments.append((prefix + ["lib", "\(framework).a"]).path)
            var headerURL: URL = prefix + "include" + framework
            if !FileManager.default.fileExists(atPath: headerURL.path) {
                headerURL = prefix + "include"
            }
            try? FileManager.default.copyItem(at: headerURL, to: frameworkDir + "Headers")
        }
        arguments.append("-output")
        arguments.append((frameworkDir + framework).path)
        try Utility.launch(path: "/usr/bin/lipo", arguments: arguments)
        try FileManager.default.createDirectory(at: frameworkDir + "Modules", withIntermediateDirectories: true, attributes: nil)
        var modulemap = """
        framework module \(framework) [system] {
            umbrella "."

        """
        frameworkExcludeHeaders(framework).forEach { header in
            modulemap += """
                exclude header "\(header).h"

            """
        }
        modulemap += """
            export *
        }
        """
        FileManager.default.createFile(atPath: frameworkDir.path + "/Modules/module.modulemap", contents: modulemap.data(using: .utf8), attributes: nil)
        createPlist(path: frameworkDir.path + "/Info.plist", name: framework, minVersion: platform.minVersion, platform: platform.sdk())
        return frameworkDir.path
    }

    fileprivate func thinDir(platform: PlatformType, arch: ArchType) -> URL {
        URL.currentDirectory + [library.rawValue, platform.rawValue, "thin", arch.rawValue]
    }

    fileprivate func scratch(platform: PlatformType, arch: ArchType) -> URL {
        URL.currentDirectory + [library.rawValue, platform.rawValue, "scratch", arch.rawValue]
    }

    func frameworkExcludeHeaders(_: String) -> [String] {
        []
    }

    private func createPlist(path: String, name: String, minVersion: String, platform: String) {
        let identifier = "com.kintan.ksplayer." + name
        let content = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleExecutable</key>
        <string>\(name)</string>
        <key>CFBundleIdentifier</key>
        <string>\(identifier)</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>\(name)</string>
        <key>CFBundlePackageType</key>
        <string>FMWK</string>
        <key>CFBundleShortVersionString</key>
        <string>87.88.520</string>
        <key>CFBundleVersion</key>
        <string>87.88.520</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>MinimumOSVersion</key>
        <string>\(minVersion)</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
        <string>\(platform)</string>
        </array>
        <key>NSPrincipalClass</key>
        <string></string>
        </dict>
        </plist>
        """
        FileManager.default.createFile(atPath: path, contents: content.data(using: .utf8), attributes: nil)
    }

    private func createMesonCrossFile(platform: PlatformType, arch: ArchType) -> URL {
        let url = scratch(platform: platform, arch: arch)
        let crossFile = url + "crossFile.meson"
        let prefix = thinDir(platform: platform, arch: arch)
        let content = """
        [binaries]
        c = ['/usr/bin/clang', '-arch', '\(arch.rawValue)']
        cpp = ['/usr/bin/clang++', '-arch', '\(arch.rawValue)']
        objc = ['/usr/bin/clang', '-arch', '\(arch.rawValue)']
        objcpp = ['/usr/bin/clang++', '-arch', '\(arch.rawValue)']
        ar = '\(platform.xcrunFind(tool: "ar"))'
        strip = '\(platform.xcrunFind(tool: "strip"))'
        pkgconfig = 'pkg-config'

        [properties]
        has_function_printf = true
        has_function_hfkerhisadf = false

        [host_machine]
        system = 'darwin'
        subsystem = '\(platform.rawValue)'
        kernel = 'xnu'
        cpu_family = '\(arch.cpuFamily())'
        cpu = '\(arch.targetCpu())'
        endian = 'little'

        [built-in options]
        default_library = 'static'
        buildtype = 'release'
        prefix = '\(prefix.path)'
        """
        FileManager.default.createFile(atPath: crossFile.path, contents: content.data(using: .utf8), attributes: nil)
        return crossFile
    }
}

private class BuildFFMPEG: BaseBuild {
    init() {
        super.init(library: .FFmpeg)
        if Utility.shell("which nasm") == nil {
            Utility.shell("brew install nasm")
        }
        if Utility.shell("which sdl2-config") == nil {
            Utility.shell("brew install sdl2")
        }
        let lldbFile = URL.currentDirectory + "LLDBInitFile"
        try? FileManager.default.removeItem(at: lldbFile)
        FileManager.default.createFile(atPath: lldbFile.path, contents: nil, attributes: nil)
        let path = directoryURL + "libavcodec/videotoolbox.c"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: "kCVPixelBufferOpenGLESCompatibilityKey", with: "kCVPixelBufferMetalCompatibilityKey")
            str = str.replacingOccurrences(of: "kCVPixelBufferIOSurfaceOpenGLTextureCompatibilityKey", with: "kCVPixelBufferMetalCompatibilityKey")
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }

    override func build(platform: PlatformType, arch: ArchType, buildURL: URL) throws {
        try super.build(platform: platform, arch: arch, buildURL: buildURL)
        let prefix = thinDir(platform: platform, arch: arch)
        let lldbFile = URL.currentDirectory + "LLDBInitFile"
        if let data = FileManager.default.contents(atPath: lldbFile.path), var str = String(data: data, encoding: .utf8) {
            str.append("settings \(str.count == 0 ? "set" : "append") target.source-map \((buildURL + "src").path) \(directoryURL.path)\n")
            try str.write(toFile: lldbFile.path, atomically: true, encoding: .utf8)
        }
        try FileManager.default.copyItem(at: buildURL + "config.h", to: prefix + "include/libavutil/config.h")
        try FileManager.default.copyItem(at: buildURL + "config.h", to: prefix + "include/libavcodec/config.h")
        try FileManager.default.copyItem(at: buildURL + "config.h", to: prefix + "include/libavformat/config.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/getenv_utf8.h", to: prefix + "include/libavutil/getenv_utf8.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/libm.h", to: prefix + "include/libavutil/libm.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/thread.h", to: prefix + "include/libavutil/thread.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/intmath.h", to: prefix + "include/libavutil/intmath.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/mem_internal.h", to: prefix + "include/libavutil/mem_internal.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/attributes_internal.h", to: prefix + "include/libavutil/attributes_internal.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavcodec/mathops.h", to: prefix + "include/libavcodec/mathops.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavformat/os_support.h", to: prefix + "include/libavformat/os_support.h")
        let internalPath = prefix + "include/libavutil/internal.h"
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/internal.h", to: internalPath)
        if let data = FileManager.default.contents(atPath: internalPath.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: """
            #include "timer.h"
            """, with: """
            // #include "timer.h"
            """)
            str = str.replacingOccurrences(of: "kCVPixelBufferIOSurfaceOpenGLTextureCompatibilityKey", with: "kCVPixelBufferMetalCompatibilityKey")
            try str.write(toFile: internalPath.path, atomically: true, encoding: .utf8)
        }
        if platform == .macos, arch.executable() {
            let fftoolsFile = URL.currentDirectory + "../Sources/fftools"
            try? FileManager.default.removeItem(at: fftoolsFile)
            if !FileManager.default.fileExists(atPath: (fftoolsFile + "include/compat").path) {
                try FileManager.default.createDirectory(at: fftoolsFile + "include/compat", withIntermediateDirectories: true)
            }
            try FileManager.default.copyItem(at: buildURL + "src/compat/va_copy.h", to: fftoolsFile + "include/compat/va_copy.h")
            try FileManager.default.copyItem(at: buildURL + "config.h", to: fftoolsFile + "include/config.h")
            try FileManager.default.copyItem(at: buildURL + "config_components.h", to: fftoolsFile + "include/config_components.h")
            if !FileManager.default.fileExists(atPath: (fftoolsFile + "include/libavdevice").path) {
                try FileManager.default.createDirectory(at: fftoolsFile + "include/libavdevice", withIntermediateDirectories: true)
            }
            try FileManager.default.copyItem(at: buildURL + "src/libavdevice/avdevice.h", to: fftoolsFile + "include/libavdevice/avdevice.h")
            try FileManager.default.copyItem(at: buildURL + "src/libavdevice/version_major.h", to: fftoolsFile + "include/libavdevice/version_major.h")
            try FileManager.default.copyItem(at: buildURL + "src/libavdevice/version.h", to: fftoolsFile + "include/libavdevice/version.h")
            if !FileManager.default.fileExists(atPath: (fftoolsFile + "include/libpostproc").path) {
                try FileManager.default.createDirectory(at: fftoolsFile + "include/libpostproc", withIntermediateDirectories: true)
            }
            try FileManager.default.copyItem(at: buildURL + "src/libpostproc/postprocess_internal.h", to: fftoolsFile + "include/libpostproc/postprocess_internal.h")
            try FileManager.default.copyItem(at: buildURL + "src/libpostproc/postprocess.h", to: fftoolsFile + "include/libpostproc/postprocess.h")
            try FileManager.default.copyItem(at: buildURL + "src/libpostproc/version_major.h", to: fftoolsFile + "include/libpostproc/version_major.h")
            try FileManager.default.copyItem(at: buildURL + "src/libpostproc/version.h", to: fftoolsFile + "include/libpostproc/version.h")
            let ffplayFile = URL.currentDirectory + "../Sources/ffplay"
            try? FileManager.default.removeItem(at: ffplayFile)
            try FileManager.default.createDirectory(at: ffplayFile, withIntermediateDirectories: true)
            let ffprobeFile = URL.currentDirectory + "../Sources/ffprobe"
            try? FileManager.default.removeItem(at: ffprobeFile)
            try FileManager.default.createDirectory(at: ffprobeFile, withIntermediateDirectories: true)
            let ffmpegFile = URL.currentDirectory + "../Sources/ffmpeg"
            try? FileManager.default.removeItem(at: ffmpegFile)
            try FileManager.default.createDirectory(at: ffmpegFile + "include", withIntermediateDirectories: true)
            let fftools = buildURL + "src/fftools"
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: fftools.path)
            for fileName in fileNames {
                if fileName.hasPrefix("ffplay") {
                    try FileManager.default.copyItem(at: fftools + fileName, to: ffplayFile + fileName)
                } else if fileName.hasPrefix("ffprobe") {
                    try FileManager.default.copyItem(at: fftools + fileName, to: ffprobeFile + fileName)
                } else if fileName.hasPrefix("ffmpeg") {
                    if fileName.hasSuffix(".h") {
                        try FileManager.default.copyItem(at: fftools + fileName, to: ffmpegFile + "include" + fileName)
                    } else {
                        try FileManager.default.copyItem(at: fftools + fileName, to: ffmpegFile + fileName)
                    }
                } else if fileName.hasSuffix(".h") {
                    try FileManager.default.copyItem(at: fftools + fileName, to: fftoolsFile + "include" + fileName)
                } else if fileName.hasSuffix(".c") {
                    try FileManager.default.copyItem(at: fftools + fileName, to: fftoolsFile + fileName)
                }
            }
            let prefix = scratch(platform: platform, arch: arch)
            try? FileManager.default.copyItem(at: prefix + "ffmpeg", to: URL(fileURLWithPath: "/usr/local/bin/ffmpeg"))
            try? FileManager.default.copyItem(at: prefix + "ffplay", to: URL(fileURLWithPath: "/usr/local/bin/ffplay"))
            try? FileManager.default.copyItem(at: prefix + "ffprobe", to: URL(fileURLWithPath: "/usr/local/bin/ffprobe"))
        }
    }

    override func frameworkExcludeHeaders(_ framework: String) -> [String] {
        if framework == "Libavcodec" {
            return ["xvmc", "vdpau", "qsv", "dxva2", "d3d11va", "mathops", "videotoolbox"]
        } else if framework == "Libavutil" {
            return ["hwcontext_vulkan", "hwcontext_vdpau", "hwcontext_vaapi", "hwcontext_qsv", "hwcontext_opencl", "hwcontext_dxva2", "hwcontext_d3d11va", "hwcontext_cuda", "hwcontext_videotoolbox", "getenv_utf8", "intmath", "libm", "thread", "mem_internal", "internal", "attributes_internal"]
        } else if framework == "Libavformat" {
            return ["os_support"]
        } else {
            return super.frameworkExcludeHeaders(framework)
        }
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var arguments = ["--prefix=\(thinDir(platform: platform, arch: arch).path)"]
        arguments += ffmpegConfiguers
        arguments += Build.ffmpegConfiguers
        arguments.append("--arch=\(arch.arch())")
        arguments.append("--target-os=darwin")
        // arguments.append(arch.cpu())
        /**
         aacpsdsp.o), building for Mac Catalyst, but linking in object file built for
         x86_64 binaries are built without ASM support, since ASM for x86_64 is actually x86 and that confuses `xcodebuild -create-xcframework` https://stackoverflow.com/questions/58796267/building-for-macos-but-linking-in-object-file-built-for-free-standing/59103419#59103419
         */
        if platform == .maccatalyst || arch == .x86_64 {
            arguments.append("--disable-neon")
            arguments.append("--disable-asm")
        } else {
            arguments.append("--enable-neon")
            arguments.append("--enable-asm")
        }
        if ![.watchsimulator, .watchos].contains(platform) {
            arguments.append("--enable-videotoolbox")
            arguments.append("--enable-audiotoolbox")
            arguments.append("--enable-filter=yadif_videotoolbox")
        }
        if platform == .macos, arch.executable() {
            arguments.append("--enable-ffplay")
            arguments.append("--enable-sdl2")
            arguments.append("--enable-encoder=aac")
            arguments.append("--enable-encoder=movtext")
            arguments.append("--enable-encoder=mpeg4")
            arguments.append("--enable-decoder=rawvideo")
            arguments.append("--enable-filter=color")
            arguments.append("--enable-filter=lut")
            arguments.append("--enable-filter=testsrc")
            arguments.append("--disable-avdevice")
            //            arguments.append("--enable-avdevice")
            //            arguments.append("--enable-indev=lavfi")
        } else {
            arguments.append("--disable-avdevice")
            arguments.append("--disable-programs")
        }
        //        if platform == .isimulator || platform == .tvsimulator {
        //            arguments.append("--assert-level=1")
        //        }
        for library in Library.allCases {
            let path = URL.currentDirectory + [library.rawValue, platform.rawValue, "thin", arch.rawValue]
            if FileManager.default.fileExists(atPath: path.path), library.isFFmpegDependentLibrary {
                arguments.append("--enable-\(library.rawValue)")
                if library == .libsrt {
                    arguments.append("--enable-protocol=\(library.rawValue)")
                } else if library == .libdav1d {
                    arguments.append("--enable-decoder=\(library.rawValue)")
                } else if library == .libass {
                    arguments.append("--enable-filter=ass")
                }
            }
        }
        return arguments
    }

    private let ffmpegConfiguers = [
        // Configuration options:
        "--disable-armv5te", "--disable-armv6", "--disable-armv6t2",
        "--disable-bzlib", "--disable-gray", "--disable-iconv", "--disable-linux-perf",
        "--disable-xlib", "--disable-swscale-alpha", "--disable-symver", "--disable-small",
        "--enable-cross-compile", "--enable-gpl", "--enable-libxml2", "--enable-nonfree",
        "--enable-runtime-cpudetect", "--enable-thumb", "--enable-version3", "--pkg-config-flags=--static",
        "--enable-static", "--disable-shared", "--enable-pic",
        // Documentation options:
        "--disable-doc", "--disable-htmlpages", "--disable-manpages", "--disable-podpages", "--disable-txtpages",
        // Component options:
        "--enable-avcodec", "--enable-avformat", "--enable-avutil", "--enable-network", "--enable-swresample", "--enable-swscale",
        "--disable-devices", "--disable-outdevs", "--disable-indevs", "--disable-postproc",
        // ,"--disable-pthreads"
        // ,"--disable-w32threads"
        // ,"--disable-os2threads"
        // ,"--disable-dct"
        // ,"--disable-dwt"
        // ,"--disable-lsp"
        // ,"--disable-lzo"
        // ,"--disable-mdct"
        // ,"--disable-rdft"
        // ,"--disable-fft"
        // Hardware accelerators:
        "--disable-d3d11va", "--disable-dxva2", "--disable-vaapi", "--disable-vdpau",
        // Individual component options:
        // ,"--disable-everything"
        // ./configure --list-muxers
        "--disable-muxers",
        "--enable-muxer=dash", "--enable-muxer=hevc", "--enable-muxer=mp4", "--enable-muxer=m4v", "--enable-muxer=mov",
        "--enable-muxer=mpegts", "--enable-muxer=webm*",
        // ./configure --list-encoders
        "--disable-encoders",
        // ./configure --list-protocols
        "--enable-protocols",
        // ./configure --list-demuxers
        // 用所有的demuxers的话，那avformat就会达到8MB了，指定的话，那就只要4MB。
        "--disable-demuxers",
        "--enable-demuxer=aac", "--enable-demuxer=ac3", "--enable-demuxer=aiff", "--enable-demuxer=amr",
        "--enable-demuxer=ape", "--enable-demuxer=asf", "--enable-demuxer=ass", "--enable-demuxer=av1",
        "--enable-demuxer=avi", "--enable-demuxer=caf",
        "--enable-demuxer=concat", "--enable-demuxer=dash", "--enable-demuxer=data", "--enable-demuxer=eac3",
        "--enable-demuxer=flac", "--enable-demuxer=flv", "--enable-demuxer=h264", "--enable-demuxer=hevc",
        "--enable-demuxer=hls", "--enable-demuxer=live_flv", "--enable-demuxer=loas", "--enable-demuxer=m4v",
        "--enable-demuxer=matroska", "--enable-demuxer=mov", "--enable-demuxer=mp3", "--enable-demuxer=mpeg*",
        "--enable-demuxer=ogg", "--enable-demuxer=rm", "--enable-demuxer=rtsp", "--enable-demuxer=rtp", "--enable-demuxer=srt",
        "--enable-demuxer=vc1", "--enable-demuxer=wav", "--enable-demuxer=webm_dash_manifest",
        // ./configure --list-bsfs
        "--enable-bsfs",
        // ./configure --list-decoders
        // 用所有的decoders的话，那avcodec就会达到40MB了，指定的话，那就只要20MB。
        "--disable-decoders",
        // 视频
        "--enable-decoder=av1", "--enable-decoder=dca", "--enable-decoder=flv", "--enable-decoder=h263",
        "--enable-decoder=h263i", "--enable-decoder=h263p", "--enable-decoder=h264", "--enable-decoder=hevc",
        "--enable-decoder=mjpeg", "--enable-decoder=mjpegb", "--enable-decoder=mpeg1video", "--enable-decoder=mpeg2video",
        "--enable-decoder=mpeg4", "--enable-decoder=mpegvideo",
        "--enable-decoder=rv10", "--enable-decoder=rv20", "--enable-decoder=rv30", "--enable-decoder=rv40",
        "--enable-decoder=tscc", "--enable-decoder=wmv1", "--enable-decoder=wmv2", "--enable-decoder=wmv3",
        "--enable-decoder=vc1", "--enable-decoder=vp6", "--enable-decoder=vp6a", "--enable-decoder=vp6f",
        "--enable-decoder=vp7", "--enable-decoder=vp8", "--enable-decoder=vp9",
        // 音频
        "--enable-decoder=aac*", "--enable-decoder=ac3*", "--enable-decoder=alac*",
        "--enable-decoder=amr*", "--enable-decoder=ape", "--enable-decoder=cook",
        "--enable-decoder=dca", "--enable-decoder=dolby_e", "--enable-decoder=eac3*", "--enable-decoder=flac",
        "--enable-decoder=mp1*", "--enable-decoder=mp2*", "--enable-decoder=mp3*", "--enable-decoder=opus",
        "--enable-decoder=pcm*", "--enable-decoder=truehd", "--enable-decoder=vorbis", "--enable-decoder=wma*",
        // 字幕
        "--enable-decoder=ass", "--enable-decoder=ccaption", "--enable-decoder=dvbsub", "--enable-decoder=dvdsub", "--enable-decoder=movtext",
        "--enable-decoder=pgssub", "--enable-decoder=srt", "--enable-decoder=ssa", "--enable-decoder=subrip",
        "--enable-decoder=webvtt",
        // ./configure --list-filters
        "--disable-filters",
        "--enable-filter=aformat", "--enable-filter=amix", "--enable-filter=anull", "--enable-filter=aresample",
        "--enable-filter=areverse", "--enable-filter=asetrate", "--enable-filter=atempo", "--enable-filter=atrim",
        "--enable-filter=bwdif", "--enable-filter=delogo",
        "--enable-filter=equalizer", "--enable-filter=estdif",
        "--enable-filter=firequalizer", "--enable-filter=format", "--enable-filter=fps",
        "--enable-filter=hflip", "--enable-filter=hwdownload", "--enable-filter=hwmap", "--enable-filter=hwupload",
        "--enable-filter=idet", "--enable-filter=lenscorrection", "--enable-filter=negate", "--enable-filter=null",
        "--enable-filter=overlay",
        "--enable-filter=palettegen", "--enable-filter=paletteuse", "--enable-filter=pan",
        "--enable-filter=rotate",
        "--enable-filter=scale", "--enable-filter=setpts", "--enable-filter=subtitles", "--enable-filter=superequalizer",
        "--enable-filter=transpose", "--enable-filter=trim",
        "--enable-filter=vflip", "--enable-filter=volume",
        "--enable-filter=w3fdif",
        "--enable-filter=yadif",
    ]
}

private class BuildOpenSSL: BaseBuild {
    init() {
        super.init(library: .openssl)
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var array = ["--prefix=\(thinDir(platform: platform, arch: arch).path)",
                     arch == .x86_64 ? "darwin64-x86_64" : arch == .arm64e ? "iphoneos-cross" : "darwin64-arm64",
                     "no-async", "no-shared", "no-dso", "no-engine", "no-tests"]
        if [PlatformType.tvos, .tvsimulator, .watchos, .watchsimulator].contains(platform) {
            array.append("-DHAVE_FORK=0")
        }
        return array
    }
}

private class BuildLibreSSL: BaseBuild {
    init() {
        super.init(library: .libtls)
    }

    override func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        var env = super.environment(platform: platform, arch: arch)
        if [PlatformType.tvos, .tvsimulator, .watchos, .watchsimulator].contains(platform) {
            env["CFLAGS"]? += " -DOPENSSL_NO_SPEED=1"
        }
        return env
    }
}

private class BuildSmbclient: BaseBuild {
    init() {
        super.init(library: .libsmbclient)
        try? Utility.launch(executableURL: directoryURL + "bootstrap/config.py", arguments: [], currentDirectoryURL: directoryURL)
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        super.arguments(platform: platform, arch: arch) +
            [
                //                "--bundled-libraries=NONE,ldb,tdb,tevent",
                "--disable-cephfs",
                "--disable-cups",
                "--disable-iprint",
                "--disable-glusterfs",
                "--without-acl-support",
                "--disable-python",
                "--without-ads",
                "--without-ldap",
                "--without-pam",
                "--without-regedit",
                "--without-syslog",
                "--without-utmp",
                "--without-winbind",
//                "--with-system-mitkrb5",
//                "--cross-compile",
//                "--cross-answers=cross-answers.txt",
//                "--cross-execute=./buildtools/example/run_on_target.py",
                "--with-static-modules=ALL",
                "--with-shared-modules=!vfs_snapper",
                "--builtin-libraries=smbclient",
//                "--targets=smbclient",
                "--hostcc=\(platform.host(arch: arch))",
                "--without-ad-dc",
                "--without-json",
                "--without-libarchive",
                "--without-acl-support",
            ]
    }

    override func build(platform: PlatformType, arch: ArchType, buildURL _: URL) throws {
        try super.build(platform: platform, arch: arch, buildURL: directoryURL)
    }
}

private class BuildGmp: BaseBuild {
    init() {
        super.init(library: .gmp)
        if Utility.shell("which makeinfo") == nil {
            Utility.shell("brew install texinfo")
        }
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        super.arguments(platform: platform, arch: arch) +
            [
                "--disable-maintainer-mode",
                "--disable-assembly",
                "--with-pic",
                "--enable-static",
                "--disable-shared",
                "--disable-fast-install",
            ]
    }
}

private class BuildNettle: BaseBuild {
    init() {
        if Utility.shell("which autoconf") == nil {
            Utility.shell("brew install autoconf")
        }
        super.init(library: .nettle)
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        super.arguments(platform: platform, arch: arch) +
            [
                "--disable-mini-gmp",
                "--disable-assembler",
                "--disable-openssl",
                "--disable-gcov",
                "--disable-documentation",
                "--enable-pic",
                "--enable-static",
                "--disable-shared",
                arch == .arm64 || arch == .arm64e ? "--enable-arm-neon" : "--enable-x86-aesni",
            ]
    }
}

private class BuildGnutls: BaseBuild {
    init() {
        if Utility.shell("which automake") == nil {
            Utility.shell("brew install automake")
        }
        if Utility.shell("which gtkdocize") == nil {
            Utility.shell("brew install gtk-doc")
        }
        if Utility.shell("which wget") == nil {
            Utility.shell("brew install wget")
        }
        if Utility.shell("which bison") == nil {
            Utility.shell("brew install bison")
        }
        super.init(library: .gnutls)
    }

    override func configure(buildURL: URL, environ: [String: String], platform: PlatformType, arch: ArchType) throws {
        try super.configure(buildURL: buildURL, environ: environ, platform: platform, arch: arch)
        let path = directoryURL + "lib/accelerated/aarch64/Makefile.in"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: "AM_CCASFLAGS =", with: "#AM_CCASFLAGS=")
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        super.arguments(platform: platform, arch: arch) +
            [
                "--with-included-libtasn1",
                "--with-included-unistring",
                "--without-idn",
                "--without-p11-kit",
                "--without-zstd",
                "--enable-hardware-acceleration",
                "--disable-openssl-compatibility",
                "--disable-code-coverage",
                "--disable-doc",
                "--disable-manpages",
                "--disable-guile",
//                "--disable-tests",
                "--disable-tools",
                "--disable-maintainer-mode",
                "--disable-full-test-suite",
                "--with-pic",
                "--enable-static",
                "--disable-shared",
                "--disable-fast-install",
                "--disable-dependency-tracking",
            ]
    }
}

private class BuildSRT: BaseBuild {
    init() {
        super.init(library: .libsrt)
    }

    override func arguments(platform: PlatformType, arch _: ArchType) -> [String] {
        [
            "-Wno-dev",
            "-DUSE_ENCLIB=openssl",
            "-DENABLE_STDCXX_SYNC=1",
            "-DENABLE_CXX11=1",
            "-DUSE_OPENSSL_PC=1",
            "-DENABLE_DEBUG=0",
            "-DENABLE_LOGGING=0",
            "-DENABLE_HEAVY_LOGGING=0",
            "-DENABLE_APPS=0",
            "-DENABLE_SHARED=0",
            platform == .maccatalyst ? "-DENABLE_MONOTONIC_CLOCK=0" : "-DENABLE_MONOTONIC_CLOCK=1",
        ]
    }
}

private class BuildFribidi: BaseBuild {
    init() {
        super.init(library: .libfribidi)
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        [
            "-Ddeprecated=false",
            "-Ddocs=false",
            "-Dtests=false",
        ]
    }
}

private class BuildHarfbuzz: BaseBuild {
    init() {
        super.init(library: .harfbuzz)
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        [
            "-Dglib=disabled",
            "-Ddocs=disabled",
        ]
    }
}

private class BuildFreetype: BaseBuild {
    init() {
        super.init(library: .libfreetype)
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        ["-Dharfbuzz=disabled"]
    }
}

private class BuildPng: BaseBuild {
    init() {
        super.init(library: .png)
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        ["-DPNG_HARDWARE_OPTIMIZATIONS=yes"]
    }
}

private class BuildASS: BaseBuild {
    init() {
        super.init(library: .libass)
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var result = super.arguments(platform: platform, arch: arch) +
            [
                "--disable-libtool-lock",
                "--disable-fontconfig",
                "--disable-require-system-font-provider",
                "--disable-test",
                "--disable-profile",
                "--disable-coretext",
                "--with-pic",
                "--enable-static",
                "--disable-shared",
                "--disable-fast-install",
                "--disable-dependency-tracking",
            ]
        if arch == .x86_64 {
            result.append("--enable-asm")
        }
        return result
    }
}

private class BuildDav1d: BaseBuild {
    init() {
        super.init(library: .libdav1d)
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        ["-Denable_asm=true", "-Denable_tools=false", "-Denable_examples=false", "-Denable_tests=false"]
    }
}

private class BuildMPV: BaseBuild {
    init() {
        super.init(library: .mpv)
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var array = [
            "-Dlibmpv=true",
        ]
        if !(platform == .macos && arch.executable()) {
            array.append("-Dcplayer=false")
        }
        if platform == .macos {
            array.append("-Dswift-flags=-sdk \(platform.isysroot()) -target \(platform.deploymentTarget(arch: arch))")
            array.append("-Dvideotoolbox-gl=enabled")
        } else {
            array.append("-Dvideotoolbox-gl=disabled")
            array.append("-Dswift-build=disabled")
            if platform == .xros || platform == .xrsimulator || platform == .maccatalyst {
                array.append("-Dios-gl=disabled")
                if platform == .maccatalyst {
                    array.append("-Dcocoa=disabled")
                    array.append("-Dcoreaudio=disabled")
                }
            } else {
                array.append("-Dios-gl=enabled")
            }
        }
        return array
    }
}

private enum PlatformType: String, CaseIterable {
    case ios, isimulator, tvos, tvsimulator, macos, maccatalyst, watchos, watchsimulator, xros, xrsimulator
    var minVersion: String {
        switch self {
        case .ios, .isimulator:
            return "13.0"
        case .tvos, .tvsimulator:
            return "13.0"
        case .macos:
            return "10.15"
        case .maccatalyst:
            return "13.0"
        case .watchos, .watchsimulator:
            return "6.0"
        case .xros, .xrsimulator:
            return "1.0"
        }
    }

    func architectures() -> [ArchType] {
        switch self {
        case .ios, .xros:
            return [.arm64, .arm64e]
        case .tvos, .watchos:
            return [.arm64]
        case .isimulator, .tvsimulator, .watchsimulator, .xrsimulator:
            return [.arm64, .x86_64]
        case .macos:
            #if arch(x86_64)
            return [.x86_64, .arm64]
            #else
            return [.arm64, .x86_64]
            #endif
        case .maccatalyst:
            return [.arm64, .x86_64]
        }
    }

    func host(arch: ArchType) -> String {
        switch self {
        case .macos:
            return "\(arch.targetCpu())-apple-darwin"
        case .ios, .tvos, .watchos, .xros:
            return "\(arch.targetCpu())-\(rawValue)-darwin"
        case .isimulator, .maccatalyst:
            return PlatformType.ios.host(arch: arch)
        case .tvsimulator:
            return PlatformType.tvos.host(arch: arch)
        case .watchsimulator:
            return PlatformType.watchos.host(arch: arch)
        case .xrsimulator:
            return PlatformType.xros.host(arch: arch)
        }
    }

    fileprivate func deploymentTarget(arch: ArchType) -> String {
        switch self {
        case .ios, .tvos, .watchos, .macos, .xros:
            return "\(arch.targetCpu())-apple-\(rawValue)\(minVersion)"
        case .maccatalyst:
            return "\(arch.targetCpu())-apple-ios-macabi"
        case .isimulator:
            return PlatformType.ios.deploymentTarget(arch: arch) + "-simulator"
        case .tvsimulator:
            return PlatformType.tvos.deploymentTarget(arch: arch) + "-simulator"
        case .watchsimulator:
            return PlatformType.watchos.deploymentTarget(arch: arch) + "-simulator"
        case .xrsimulator:
            return PlatformType.xros.deploymentTarget(arch: arch) + "-simulator"
        }
    }

    private func osVersionMin() -> String {
        switch self {
        case .ios, .tvos, .watchos:
            return " -m\(rawValue)-version-min=\(minVersion)"
        case .macos:
            return " -mmacosx-version-min=\(minVersion)"
        case .isimulator:
            return " -mios-simulator-version-min=\(minVersion)"
        case .tvsimulator:
            return " -mtvos-simulator-version-min=\(minVersion)"
        case .watchsimulator:
            return " -mwatchos-simulator-version-min=\(minVersion)"
        case .maccatalyst, .xros, .xrsimulator:
            return ""
        }
    }

    func sdk() -> String {
        switch self {
        case .ios:
            return "iPhoneOS"
        case .isimulator:
            return "iPhoneSimulator"
        case .tvos:
            return "AppleTVOS"
        case .tvsimulator:
            return "AppleTVSimulator"
        case .watchos:
            return "WatchOS"
        case .watchsimulator:
            return "WatchSimulator"
        case .xros:
            return "XROS"
        case .xrsimulator:
            return "XRSimulator"
        case .macos, .maccatalyst:
            return "MacOSX"
        }
    }

    func ldFlags(arch: ArchType) -> [String] {
        // ldFlags的关键参数要跟cFlags保持一致，不然会在ld的时候不通过。
        var flags = ["-arch", arch.rawValue, "-isysroot", isysroot(), "-target", deploymentTarget(arch: arch)]
        let gmpPath = URL.currentDirectory + [Library.gmp.rawValue, rawValue, "thin", arch.rawValue]
        if FileManager.default.fileExists(atPath: gmpPath.path) {
            flags.append("-L\(gmpPath.path)/lib")
        }
        return flags
    }

    func cFlags(arch: ArchType) -> String {
        let isysroot = isysroot()
        var cflags = "-arch \(arch.rawValue) -isysroot \(isysroot) -target \(deploymentTarget(arch: arch))"
            + osVersionMin()
//        if self == .macos || self == .maccatalyst {
        // 不能同时有强符合和弱符号出现
        cflags += " -fno-common"
//        }
        if self == .maccatalyst {
            cflags += " -iframework \(isysroot)/System/iOSSupport/System/Library/Frameworks"
        }
        let gmpPath = URL.currentDirectory + [Library.gmp.rawValue, rawValue, "thin", arch.rawValue]
        if FileManager.default.fileExists(atPath: gmpPath.path) {
            cflags += " -I\(gmpPath.path)/include"
        }
        return cflags
    }

    func isysroot() -> String {
        xcrunFind(tool: "--show-sdk-path")
    }

    func xcrunFind(tool: String) -> String {
        try! Utility.launch(path: "/usr/bin/xcrun", arguments: ["--sdk", sdk().lowercased(), "--find", tool], isOutput: true)
    }

    func pkgConfigPath(arch: ArchType) -> String {
        var pkgConfigPath = ""
        for lib in Library.allCases {
            let path = URL.currentDirectory + [lib.rawValue, rawValue, "thin", arch.rawValue]
            if FileManager.default.fileExists(atPath: path.path) {
                pkgConfigPath += "\(path.path)/lib/pkgconfig:"
            }
        }
        return pkgConfigPath
    }
}

enum ArchType: String, CaseIterable {
    // swiftlint:disable identifier_name
    case arm64, x86_64, arm64e
    // swiftlint:enable identifier_name
    func executable() -> Bool {
        guard let architecture = Bundle.main.executableArchitectures?.first?.intValue else {
            return false
        }
        // NSBundleExecutableArchitectureARM64
        if architecture == 0x0100_000C, self == .arm64 {
            return true
        } else if architecture == NSBundleExecutableArchitectureX86_64, self == .x86_64 {
            return true
        }
        return false
    }

    func arch() -> String {
        switch self {
        case .arm64, .arm64e:
            return "aarch64"
        case .x86_64:
            return "x86_64"
        }
    }

    func cpuFamily() -> String {
        switch self {
        case .arm64, .arm64e:
            return "aarch64"
        case .x86_64:
            return "x86_64"
        }
    }

    func targetCpu() -> String {
        switch self {
        case .arm64, .arm64e:
            return "arm64"
        case .x86_64:
            return "x86_64"
        }
    }
}

enum Utility {
    @discardableResult
    static func shell(_ command: String, isOutput: Bool = false, currentDirectoryURL: URL? = nil, environment: [String: String] = [:]) -> String? {
        do {
            return try launch(executableURL: URL(fileURLWithPath: "/bin/zsh"), arguments: ["-c", command], isOutput: isOutput, currentDirectoryURL: currentDirectoryURL, environment: environment)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    @discardableResult
    static func launch(path: String, arguments: [String], isOutput: Bool = false, currentDirectoryURL: URL? = nil, environment: [String: String] = [:]) throws -> String {
        try launch(executableURL: URL(fileURLWithPath: path), arguments: arguments, isOutput: isOutput, currentDirectoryURL: currentDirectoryURL, environment: environment)
    }

    @discardableResult
    static func launch(executableURL: URL, arguments: [String], isOutput: Bool = false, currentDirectoryURL: URL? = nil, environment: [String: String] = [:]) throws -> String {
        #if os(macOS)
        let task = Process()
        var environment = environment
        environment["PATH"] = "/usr/local/bin:/opt/homebrew/bin:/usr/local/opt/bison/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        task.environment = environment
        var standardOutput: FileHandle?
        var log = executableURL.path + " " + arguments.joined(separator: " ") + " environment: " + environment.description
        if isOutput {
            let pipe = Pipe()
            task.standardOutput = pipe
            standardOutput = pipe.fileHandleForReading
        } else if var logURL = currentDirectoryURL {
            logURL = logURL.appendingPathExtension("log")
            log += " logFile: \(logURL)"

            if !FileManager.default.fileExists(atPath: logURL.path) {
                FileManager.default.createFile(atPath: logURL.path, contents: nil)
            }
            let standardOutput = try FileHandle(forWritingTo: logURL)
            if #available(macOS 10.15.4, *) {
                try standardOutput.seekToEnd()
            }
            task.standardOutput = standardOutput
        }
        print(log)
        task.arguments = arguments
        task.currentDirectoryURL = currentDirectoryURL
        task.executableURL = executableURL
        try task.run()
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            if isOutput, let standardOutput {
                let data = standardOutput.readDataToEndOfFile()
                let result = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines) ?? ""
                print(result)
                return result
            } else {
                return ""
            }
        } else {
            throw NSError(domain: "fail", code: Int(task.terminationStatus))
        }
        #else
        return ""
        #endif
    }
}

extension URL {
    static var currentDirectory: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    static func + (left: URL, right: String) -> URL {
        var url = left
        url.appendPathComponent(right)
        return url
    }

    static func + (left: URL, right: [String]) -> URL {
        var url = left
        right.forEach {
            url.appendPathComponent($0)
        }
        return url
    }
}
