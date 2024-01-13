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
            if argument == "notRecompile" {
                BaseBuild.notRecompile = true
            } else if argument == "gitCloneAll" {
                BaseBuild.gitCloneAll = true
            } else if argument == "enable-debug" {
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
            Build.ffmpegConfiguers.append("--enable-debug=3")
            Build.ffmpegConfiguers.append("--disable-stripping")
        } else {
            Build.ffmpegConfiguers.append("--disable-debug")
            Build.ffmpegConfiguers.append("--enable-stripping")
        }
        if arguments.isEmpty {
            librarys.append(contentsOf: [.libshaderc, .vulkan, .lcms2, .libplacebo, .libdav1d, .gmp, .nettle, .gnutls, .readline, .libsmbclient, .libsrt, .libzvbi, .libfreetype, .libfribidi, .libharfbuzz, .libass, .FFmpeg, .libmpv])
        }
        for library in librarys {
            try library.build.buildALL()
        }
    }

    static func printHelp() {
        print("""
        Usage: swift package BuildFFmpeg [OPTION]...
        Default Build: swift package --disable-sandbox BuildFFmpeg enable-libshaderc enable-vulkan enable-lcms2 enable-libdav1d enable-libplacebo enable-gmp enable-nettle enable-gnutls enbale-readline enable-libsmbclient enable-libsrt enable-libzvbi enable-libfreetype enable-libfribidi enable-libharfbuzz enable-libass enable-FFmpeg enable-libmpv

        Options:
            h, -h, --help       display this help and exit
            notRecompile        If there is a library, then there is no need to recompile
            gitCloneAll         git clone not add --depth 1
            enable-debug,       build ffmpeg with debug information
            platforms=xros      deployment platform: macos,ios,isimulator,tvos,tvsimulator,xros,xrsimulator,maccatalyst,watchos,watchsimulator
            --xx                add ffmpeg Configuers

        Libraries:
            enable-libshaderc   build with libshaderc
            enable-vulkan       depend enable-libshaderc
            enable-libdav1d     build with libdav1d
            enable-libplacebo   depend enable-libshaderc enable-vulkan enable-lcms2 enable-libdav1d
            enable-nettle       depend enable-gmp
            enable-gnutls       depend enable-gmp enable-nettle
            enable-libsmbclient depend enable-gmp enable-nettle enable-gnutls enbale-readline
            enable-libsrt       depend enable-openssl or enable-gnutls
            enable-libfreetype  build with libfreetype
            enable-libharfbuzz  depend enable-libfreetype
            enable-libass       depend enable-libfreetype enable-libfribidi enable-libharfbuzz
            enable-libzvbi      build with libzvbi
            enable-FFmpeg       build with FFmpeg
            enable-libmpv       depend enable-libass enable-FFmpeg
            enable-openssl      build with openssl [no]
        """)
    }
}

enum Library: String, CaseIterable {
    case libglslang, libshaderc, vulkan, lcms2, libdovi, libdav1d, libplacebo, libfreetype, libharfbuzz, libfribidi, libass, gmp, readline, nettle, gnutls, libsmbclient, libsrt, libzvbi, FFmpeg, libmpv, openssl, libtls, boringssl, libpng, libupnp, libnfs
    var version: String {
        switch self {
        case .FFmpeg:
            return "n6.1"
        case .libfreetype:
            return "VER-2-12-1"
        case .libfribidi:
            return "v1.0.12"
        case .libharfbuzz:
            return "5.3.1"
        case .libass:
            return "0.17.1-branch"
        case .libpng:
            return "v1.6.40"
        case .libmpv:
            return "v0.37.0"
        case .openssl:
            return "openssl-3.2.0"
        case .libsrt:
            return "v1.5.1"
        case .libsmbclient:
            return "samba-4.15.13"
        case .gnutls:
            return "3.8.2"
        case .nettle:
            return "nettle_3.9.1_release_20230601"
        case .libdav1d:
            return "1.1.0"
        case .gmp:
            return "v6.2.1"
        case .libtls:
            return "OPENBSD_7_3"
        case .libzvbi:
            return "v0.2.42"
        case .boringssl:
            return "master"
        case .libplacebo:
            return "v6.338.1"
        case .vulkan:
            return "v1.2.6"
        case .libshaderc:
            return "v2023.7"
        case .readline:
            return "readline-8.2"
        case .libglslang:
            return "13.1.1"
        case .libdovi:
            return "2.1.0"
        case .lcms2:
            return "lcms2.16"
        case .libupnp:
            return "release-1.14.18"
        case .libnfs:
            return "libnfs-5.0.2"
        }
    }

    var url: String {
        switch self {
        case .libpng:
            return "https://github.com/glennrp/libpng"
        case .libmpv:
            return "https://github.com/mpv-player/mpv"
        case .libsrt:
            return "https://github.com/Haivision/srt"
        case .libsmbclient:
            return "https://github.com/samba-team/samba"
        case .nettle:
            return "https://git.lysator.liu.se/nettle/nettle"
        case .gmp:
            return "https://github.com/alisw/GMP"
        case .libdav1d:
            return "https://github.com/videolan/dav1d"
        case .libtls:
            return "https://github.com/libressl/portable"
        case .libzvbi:
            return "https://github.com/zapping-vbi/zvbi"
        case .boringssl:
            return "https://github.com/google/boringssl"
        case .libplacebo:
            return "https://github.com/haasn/libplacebo"
        case .vulkan:
            return "https://github.com/KhronosGroup/MoltenVK"
        case .libshaderc:
            return "https://github.com/google/shaderc"
        case .readline:
            return "https://git.savannah.gnu.org/git/readline.git"
        case .libglslang:
            return "https://github.com/KhronosGroup/glslang"
        case .libdovi:
            return "https://github.com/quietvoid/dovi_tool"
        case .lcms2:
            return "https://github.com/mm2/Little-CMS"
        case .libupnp:
            return "https://github.com/pupnp/pupnp"
        case .libnfs:
            return "https://github.com/sahlberg/libnfs"
        default:
            var value = rawValue
            if self != .libass, value.hasPrefix("lib") {
                value = String(value.dropFirst(3))
            }
            return "https://github.com/\(value)/\(value)"
        }
    }

    var isFFmpegDependentLibrary: Bool {
        switch self {
        case .vulkan, .libshaderc, .libglslang, .lcms2, .libplacebo, .libdav1d, .gmp, .gnutls, .libsrt, .libzvbi, .libsmbclient:
            return true
        case .openssl:
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
        case .libharfbuzz:
            return BuildHarfbuzz()
        case .libass:
            return BuildASS()
        case .libpng:
            return BuildPng()
        case .libmpv:
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
        case .libzvbi:
            return BuildZvbi()
        case .boringssl:
            return BuildBoringSSL()
        case .libplacebo:
            return BuildPlacebo()
        case .vulkan:
            return BuildVulkan()
        case .libshaderc:
            return BuildShaderc()
        case .libglslang:
            return BuildGlslang()
        case .readline:
            return BuildReadline()
        case .libdovi:
            return BuildDovi()
        case .lcms2:
            return BuildLittleCms()
        case .libupnp:
            return BuildUPnP()
        case .libnfs:
            return BuildNFS()
        }
    }
}

class BaseBuild {
    static var platforms = PlatformType.allCases
        .filter {
            ![.watchos, .watchsimulator].contains($0)
        }

    static var notRecompile = false
    static var gitCloneAll = false
    let library: Library
    let directoryURL: URL
    init(library: Library) {
        self.library = library
        directoryURL = URL.currentDirectory + "\(library.rawValue)-\(library.version)"
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            var arguments = ["clone", "--recurse-submodules"]
            if !BaseBuild.gitCloneAll {
                arguments.append(contentsOf: ["--depth", "1"])
            }
            arguments.append(contentsOf: ["--branch", library.version, library.url, directoryURL.path])
            try! Utility.launch(path: "/usr/bin/git", arguments: arguments)
        }
        let patch = URL.currentDirectory + "../Plugins/BuildFFmpeg/patch/\(library.rawValue)"
        if FileManager.default.fileExists(atPath: patch.path) {
            _ = try? Utility.launch(path: "/usr/bin/git", arguments: ["stash"], currentDirectoryURL: directoryURL)
            let fileNames = try! FileManager.default.contentsOfDirectory(atPath: patch.path).sorted()
            for fileName in fileNames {
                _ = try? Utility.launch(path: "/usr/bin/git", arguments: ["apply", "\((patch + fileName).path)"], currentDirectoryURL: directoryURL)
            }
        }
    }

    func platforms() -> [PlatformType] {
        BaseBuild.platforms
    }

    func buildALL() throws {
        for platform in platforms() {
            for arch in platform.architectures {
                let prefix = thinDir(platform: platform, arch: arch)
                if FileManager.default.fileExists(atPath: (prefix + "lib").path), BaseBuild.notRecompile {
                    continue
                }
                try? FileManager.default.removeItem(at: prefix)
                let buildURL = scratch(platform: platform, arch: arch)
                try? FileManager.default.removeItem(at: buildURL)
                try? FileManager.default.createDirectory(at: buildURL, withIntermediateDirectories: true, attributes: nil)
                try build(platform: platform, arch: arch, buildURL: buildURL)
            }
        }
        try createXCFramework()
    }

    func build(platform: PlatformType, arch: ArchType, buildURL: URL) throws {
        try? _ = Utility.launch(path: "/usr/bin/make", arguments: ["clean"], currentDirectoryURL: buildURL)
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
            let waf = (directoryURL + wafPath()).path
            try Utility.launch(path: waf, arguments: ["configure"] + arguments(platform: platform, arch: arch), currentDirectoryURL: directoryURL, environment: environ)
            var arguments = [String]()
            arguments.append(contentsOf: wafBuildArg())
            try Utility.launch(path: waf, arguments: arguments, currentDirectoryURL: directoryURL, environment: environ)
            arguments = ["install"]
            arguments.append(contentsOf: wafInstallArg())
            try Utility.launch(path: waf, arguments: arguments, currentDirectoryURL: directoryURL, environment: environ)
        } else {
            try configure(buildURL: buildURL, environ: environ, platform: platform, arch: arch)
            try Utility.launch(path: "/usr/bin/make", arguments: ["-j8"], currentDirectoryURL: buildURL, environment: environ)
            try Utility.launch(path: "/usr/bin/make", arguments: ["-j8", "install"], currentDirectoryURL: buildURL, environment: environ)
        }
    }

    func wafPath() -> String {
        "waf"
    }

    func wafBuildArg() -> [String] {
        ["build"]
    }

    func wafInstallArg() -> [String] {
        []
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
                "-DCMAKE_OSX_SYSROOT=\(platform.sdk.lowercased())",
                "-DCMAKE_OSX_ARCHITECTURES=\(arch.rawValue)",
                "-DCMAKE_INSTALL_PREFIX=\(thinDirPath)",
                "-DBUILD_SHARED_LIBS=0",
            ]
            arguments.append(contentsOf: self.arguments(platform: platform, arch: arch))
            try Utility.launch(path: cmake, arguments: arguments, currentDirectoryURL: buildURL, environment: environ)
        } else {
            let configure = directoryURL + "configure"
            if !FileManager.default.fileExists(atPath: configure.path) {
                var bootstrap = directoryURL + "bootstrap"
                if !FileManager.default.fileExists(atPath: bootstrap.path) {
                    bootstrap = directoryURL + ".bootstrap"
                }
                if FileManager.default.fileExists(atPath: bootstrap.path) {
                    try Utility.launch(executableURL: bootstrap, arguments: [], currentDirectoryURL: directoryURL, environment: environ)
                } else {
                    let autogen = directoryURL + "autogen.sh"
                    if FileManager.default.fileExists(atPath: autogen.path) {
                        var environ = environ
                        environ["NOCONFIGURE"] = "1"
                        try Utility.launch(executableURL: autogen, arguments: [], currentDirectoryURL: directoryURL, environment: environ)
                    }
                }
            }
            try Utility.launch(executableURL: configure, arguments: arguments(platform: platform, arch: arch), currentDirectoryURL: buildURL, environment: environ)
        }
    }

    func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        let cFlags = cFlags(platform: platform, arch: arch).joined(separator: " ")
        let ldFlags = ldFlags(platform: platform, arch: arch).joined(separator: " ")
        let pkgConfigPath = platform.pkgConfigPath(arch: arch)
        let pkgConfigPathDefault = Utility.shell("pkg-config --variable pc_path pkg-config", isOutput: true)!
        return [
            "LC_CTYPE": "C",
            "CC": "/usr/bin/clang",
            "CXX": "/usr/bin/clang++",
            // "SDKROOT": platform.sdk.lowercased(),
            "CURRENT_ARCH": arch.rawValue,
            "CFLAGS": cFlags,
            // makefile can't use CPPFLAGS
//            "CPPFLAGS": cFlags,
//            "CXXFLAGS": cFlags,
            "LDFLAGS": ldFlags,
//            "PKG_CONFIG_PATH": pkgConfigPath,
            "PKG_CONFIG_LIBDIR": pkgConfigPath + pkgConfigPathDefault,
            "PATH": "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:",
        ]
    }

    func cFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var cFlags = platform.cFlags(arch: arch)
        let librarys = flagsDependencelibrarys()
        for library in librarys {
            let path = thinDir(library: library, platform: platform, arch: arch)
            if FileManager.default.fileExists(atPath: path.path) {
                if library == .libsmbclient {
                    cFlags.append("-I\(path.path)/include/samba-4.0")
                } else {
                    cFlags.append("-I\(path.path)/include")
                }
            }
        }
        return cFlags
    }

    func ldFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var ldFlags = platform.ldFlags(arch: arch)
        let librarys = flagsDependencelibrarys()
        for library in librarys {
            let path = thinDir(library: library, platform: platform, arch: arch)
            if FileManager.default.fileExists(atPath: path.path) {
                var libname = library.rawValue
                if libname.hasPrefix("lib") {
                    libname = String(libname.dropFirst(3))
                }
                ldFlags.append("-L\(path.path)/lib")
                ldFlags.append("-l\(libname)")
                if library == .nettle {
                    ldFlags.append("-lhogweed")
                } else if library == .gnutls {
                    ldFlags.append(contentsOf: ["-framework", "Security", "-framework", "CoreFoundation"])
                } else if library == .libsmbclient {
                    ldFlags.append(contentsOf: ["-lresolv", "-lpthread", "-lz", "-liconv"])
                }
            }
        }
        return ldFlags
    }

    func flagsDependencelibrarys() -> [Library] {
        []
    }

    func arguments(platform _: PlatformType, arch _: ArchType) -> [String] { [] }

    func frameworks() throws -> [String] {
        [library.rawValue]
    }

    private func createXCFramework() throws {
        let frameworks = try frameworks()
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
        if !platforms().contains(platform) {
            if FileManager.default.fileExists(atPath: frameworkDir.path) {
                return frameworkDir.path
            } else {
                return nil
            }
        }
        try? FileManager.default.removeItem(at: frameworkDir)
        try FileManager.default.createDirectory(at: frameworkDir, withIntermediateDirectories: true, attributes: nil)
        var arguments = ["-create"]
        for arch in platform.architectures {
            let prefix = thinDir(platform: platform, arch: arch)
            if !FileManager.default.fileExists(atPath: prefix.path) {
                return nil
            }
            let libname = framework.hasPrefix("lib") || framework.hasPrefix("Lib") ? framework : "lib" + framework
            var libPath = prefix + ["lib", "\(libname).a"]
            if !FileManager.default.fileExists(atPath: libPath.path) {
                libPath = prefix + ["lib", "\(libname).dylib"]
            }
            arguments.append(libPath.path)
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
        for header in frameworkExcludeHeaders(framework) {
            modulemap += """
                exclude header "\(header).h"

            """
        }
        modulemap += """
            export *
        }
        """
        FileManager.default.createFile(atPath: frameworkDir.path + "/Modules/module.modulemap", contents: modulemap.data(using: .utf8), attributes: nil)
        createPlist(path: frameworkDir.path + "/Info.plist", name: framework, minVersion: platform.minVersion, platform: platform.sdk)
        return frameworkDir.path
    }

    func thinDir(library: Library, platform: PlatformType, arch: ArchType) -> URL {
        URL.currentDirectory + [library.rawValue, platform.rawValue, "thin", arch.rawValue]
    }

    func thinDir(platform: PlatformType, arch: ArchType) -> URL {
        thinDir(library: library, platform: platform, arch: arch)
    }

    func scratch(platform: PlatformType, arch: ArchType) -> URL {
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
        let cFlags = cFlags(platform: platform, arch: arch).map {
            "'" + $0 + "'"
        }.joined(separator: ", ")
        let ldFlags = ldFlags(platform: platform, arch: arch).map {
            "'" + $0 + "'"
        }.joined(separator: ", ")
        let content = """
        [binaries]
        c = '/usr/bin/clang'
        cpp = '/usr/bin/clang++'
        objc = '/usr/bin/clang'
        objcpp = '/usr/bin/clang++'
        ar = '\(platform.xcrunFind(tool: "ar"))'
        strip = '\(platform.xcrunFind(tool: "strip"))'
        pkgconfig = 'pkg-config'

        [properties]
        has_function_printf = true
        has_function_hfkerhisadf = false

        [host_machine]
        system = 'darwin'
        subsystem = '\(platform.mesonSubSystem)'
        kernel = 'xnu'
        cpu_family = '\(arch.cpuFamily)'
        cpu = '\(arch.targetCpu)'
        endian = 'little'

        [built-in options]
        default_library = 'static'
        buildtype = 'release'
        prefix = '\(prefix.path)'
        c_args = [\(cFlags)]
        cpp_args = [\(cFlags)]
        objc_args = [\(cFlags)]
        objcpp_args = [\(cFlags)]
        c_link_args = [\(ldFlags)]
        cpp_link_args = [\(ldFlags)]
        objc_link_args = [\(ldFlags)]
        objcpp_link_args = [\(ldFlags)]
        """
        FileManager.default.createFile(atPath: crossFile.path, contents: content.data(using: .utf8), attributes: nil)
        return crossFile
    }
}

class BuildZvbi: BaseBuild {
    init() {
        super.init(library: .libzvbi)
        let path = directoryURL + "configure.ac"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: "AC_FUNC_MALLOC", with: "")
            str = str.replacingOccurrences(of: "AC_FUNC_REALLOC", with: "")
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }

    override func platforms() -> [PlatformType] {
        super.platforms().filter {
            $0 != .maccatalyst
        }
    }

    override func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        var env = super.environment(platform: platform, arch: arch)
        env["CXXFLAGS"] = env["CFLAGS"]
        return env
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        ["--host=\(platform.host(arch: arch))",
         "--prefix=\(thinDir(platform: platform, arch: arch).path)"]
    }
}

class BuildSRT: BaseBuild {
    init() {
        super.init(library: .libsrt)
    }

    override func arguments(platform: PlatformType, arch _: ArchType) -> [String] {
        [
            "-Wno-dev",
//            "-DUSE_ENCLIB=openssl",
            "-DUSE_ENCLIB=gnutls",
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

class BuildUPnP: BaseBuild {
    init() {
        super.init(library: .libupnp)
    }
}

class BuildNFS: BaseBuild {
    init() {
        super.init(library: .libnfs)
    }
}

enum PlatformType: String, CaseIterable {
    case macos, ios, isimulator, tvos, tvsimulator, xros, xrsimulator, maccatalyst, watchos, watchsimulator
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

    var name: String {
        switch self {
        case .ios, .tvos, .macos:
            return rawValue
        case .tvsimulator:
            return "tvossim"
        case .isimulator:
            return "iossim"
        case .maccatalyst:
            return "maccat"
        case .watchos:
            return "watchos"
        case .watchsimulator:
            return "watchossim"
        case .xros:
            return "visionos"
        case .xrsimulator:
            return "visionossim"
        }
    }

    var frameworkName: String {
        switch self {
        case .ios:
            return "ios-arm64"
        case .maccatalyst:
            return "ios-arm64_x86_64-maccatalyst"
        case .isimulator:
            return "ios-arm64_x86_64-simulator"
        case .macos:
            return "macos-arm64_x86_64"
        case .tvos:
            return "tvos-arm64_arm64e"
        case .tvsimulator:
            return "tvos-arm64_x86_64-simulator"
        case .watchos:
            return "watchos-arm64"
        case .watchsimulator:
            return "watchossim"
        case .xros:
            return "xros-arm64"
        case .xrsimulator:
            return "xros-arm64_x86_64-simulator"
        }
    }

    var architectures: [ArchType] {
        switch self {
        case .ios, .xros, .watchos:
            return [.arm64]
        case .tvos:
            return [.arm64, .arm64e]
        case .isimulator, .tvsimulator, .watchsimulator:
            return [.arm64, .x86_64]
        case .xrsimulator:
            return [.arm64]
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

    var mesonSubSystem: String {
        switch self {
        case .isimulator:
            return "ios-simulator"
        case .tvsimulator:
            return "tvos-simulator"
        case .xrsimulator:
            return "xros-simulator"
        case .watchsimulator:
            return "watchos-simulator"
        default:
            return rawValue
        }
    }

    func host(arch: ArchType) -> String {
        switch self {
        case .macos:
            return "\(arch.targetCpu)-apple-darwin"
        case .ios, .tvos, .watchos, .xros:
            return "\(arch.targetCpu)-\(rawValue)-darwin"
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

    func deploymentTarget(arch: ArchType) -> String {
        switch self {
        case .ios, .tvos, .watchos, .macos, .xros:
            return "\(arch.targetCpu)-apple-\(rawValue)\(minVersion)"
        case .maccatalyst:
            return "\(arch.targetCpu)-apple-ios-macabi"
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

    private var osVersionMin: String {
        switch self {
        case .ios, .tvos, .watchos:
            return "-m\(rawValue)-version-min=\(minVersion)"
        case .macos:
            return "-mmacosx-version-min=\(minVersion)"
        case .isimulator:
            return "-mios-simulator-version-min=\(minVersion)"
        case .tvsimulator:
            return "-mtvos-simulator-version-min=\(minVersion)"
        case .watchsimulator:
            return "-mwatchos-simulator-version-min=\(minVersion)"
        case .maccatalyst, .xros, .xrsimulator:
            return ""
        }
    }

    var sdk: String {
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
        ["-arch", arch.rawValue, "-isysroot", isysroot, "-target", deploymentTarget(arch: arch)]
    }

    func cFlags(arch: ArchType) -> [String] {
        let isysroot = isysroot
        var cflags = ["-arch", arch.rawValue, "-isysroot", isysroot, "-target", deploymentTarget(arch: arch), osVersionMin]
//        if self == .macos || self == .maccatalyst {
        // 不能同时有强符合和弱符号出现
        cflags.append("-fno-common")
//        }
        if self == .maccatalyst {
            cflags.append("-iframework \(isysroot)/System/iOSSupport/System/Library/Frameworks")
        }
        return cflags
    }

    var isysroot: String {
        xcrunFind(tool: "--show-sdk-path")
    }

    func xcrunFind(tool: String) -> String {
        try! Utility.launch(path: "/usr/bin/xcrun", arguments: ["--sdk", sdk.lowercased(), "--find", tool], isOutput: true)
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
    // arm64e 还没ABI。所以第三方库是无法使用的。
    case arm64, x86_64, arm64e
    // swiftlint:enable identifier_name
    var executable: Bool {
        guard let architecture = Bundle.main.executableArchitectures?.first?.intValue else {
            return false
        }
        // NSBundleExecutableArchitectureARM64
        if architecture == 0x0100_000C, self == .arm64 || self == .arm64e {
            return true
        } else if architecture == NSBundleExecutableArchitectureX86_64, self == .x86_64 {
            return true
        }
        return false
    }

    var cpuFamily: String {
        switch self {
        case .arm64, .arm64e:
            return "aarch64"
        case .x86_64:
            return "x86_64"
        }
    }

    var targetCpu: String {
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
        if environment["PATH"] == nil {
            environment["PATH"] = "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        }
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
        for item in right {
            url.appendPathComponent(item)
        }
        return url
    }
}
