//
//  BuildPlacebo.swift
//
//
//  Created by kintan on 12/26/23.
//

import Foundation

class BuildPlacebo: BaseBuild {
    init() {
        super.init(library: .libplacebo)
        let path = directoryURL + "demos/meson.build"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: "if sdl.found()", with: "if false")
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        ["-Dxxhash=disabled", "-Dopengl=disabled"]
    }
}

class BuildVulkan: BaseBuild {
    init() {
        super.init(library: .vulkan)
    }

    override func buildALL() throws {
        var arguments = platforms().map {
            "--\($0.name)"
        }
        if !FileManager.default.fileExists(atPath: (directoryURL + "External/build/Release").path) {
            try Utility.launch(path: (directoryURL + "fetchDependencies").path, arguments: arguments, currentDirectoryURL: directoryURL)
        }
        arguments = platforms().map(\.name)
        try Utility.launch(path: "/usr/bin/make", arguments: arguments, currentDirectoryURL: directoryURL)
        try? FileManager.default.removeItem(at: URL.currentDirectory() + "../Sources/MoltenVK.xcframework")
        try? FileManager.default.copyItem(at: directoryURL + "Package/Release/MoltenVK/MoltenVK.xcframework", to: URL.currentDirectory() + "../Sources/MoltenVK.xcframework")
        for platform in platforms() {
            var frameworks = ["CoreFoundation", "CoreGraphics", "Foundation", "IOSurface", "Metal", "QuartzCore"]
            if platform == .macos {
                frameworks.append("Cocoa")
            } else {
                frameworks.append("UIKit")
            }
            if !(platform == .tvos || platform == .tvsimulator) {
                frameworks.append("IOKit")
            }
            let libframework = frameworks.map {
                "-framework \($0)"
            }.joined(separator: " ")
            for arch in platform.architectures {
                let prefix = thinDir(platform: platform, arch: arch) + "lib/pkgconfig"
                try? FileManager.default.removeItem(at: prefix)
                try? FileManager.default.createDirectory(at: prefix, withIntermediateDirectories: true, attributes: nil)
                let vulkanPC = prefix + "vulkan.pc"

                let content = """
                prefix=\((directoryURL + "Package/Release/MoltenVK").path)
                includedir=${prefix}/include
                libdir=${prefix}/MoltenVK.xcframework/\(platform.frameworkName)

                Name: Vulkan-Loader
                Description: Vulkan Loader
                Version: 1.2
                Libs: -L${libdir} -lMoltenVK \(libframework)
                Cflags: -I${includedir}
                """
                FileManager.default.createFile(atPath: vulkanPC.path, contents: content.data(using: .utf8), attributes: nil)
            }
        }
    }
}

class BuildGlslang: BaseBuild {
    init() {
        super.init(library: .libglslang)
        _ = try? Utility.launch(executableURL: directoryURL + "./update_glslang_sources.py", arguments: [], currentDirectoryURL: directoryURL)
        var path = directoryURL + "External/spirv-tools/tools/reduce/reduce.cpp"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: """
              int res = std::system(nullptr);
              return res != 0;
            """, with: """
              FILE* fp = popen(nullptr, "r");
              return fp == NULL;
            """)
            str = str.replacingOccurrences(of: """
              int status = std::system(command.c_str());
            """, with: """
              FILE* fp = popen(command.c_str(), "r");
            """)
            str = str.replacingOccurrences(of: """
              return status == 0;
            """, with: """
              return fp != NULL;
            """)
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
        path = directoryURL + "External/spirv-tools/tools/fuzz/fuzz.cpp"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: """
              int res = std::system(nullptr);
              return res != 0;
            """, with: """
              FILE* fp = popen(nullptr, "r");
              return fp == NULL;
            """)
            str = str.replacingOccurrences(of: """
              int status = std::system(command.c_str());
            """, with: """
              FILE* fp = popen(command.c_str(), "r");
            """)
            str = str.replacingOccurrences(of: """
              return status == 0;
            """, with: """
              return fp != NULL;
            """)
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }
}

class BuildShaderc: BaseBuild {
    init() {
        super.init(library: .libshaderc)
        _ = try? Utility.launch(executableURL: directoryURL + "utils/git-sync-deps", arguments: [], currentDirectoryURL: directoryURL)
        var path = directoryURL + "third_party/spirv-tools/tools/reduce/reduce.cpp"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: """
              int res = std::system(nullptr);
              return res != 0;
            """, with: """
              FILE* fp = popen(nullptr, "r");
              return fp == NULL;
            """)
            str = str.replacingOccurrences(of: """
              int status = std::system(command.c_str());
            """, with: """
              FILE* fp = popen(command.c_str(), "r");
            """)
            str = str.replacingOccurrences(of: """
              return status == 0;
            """, with: """
              return fp != NULL;
            """)
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
        path = directoryURL + "third_party/spirv-tools/tools/fuzz/fuzz.cpp"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: """
              int res = std::system(nullptr);
              return res != 0;
            """, with: """
              FILE* fp = popen(nullptr, "r");
              return fp == NULL;
            """)
            str = str.replacingOccurrences(of: """
              int status = std::system(command.c_str());
            """, with: """
              FILE* fp = popen(command.c_str(), "r");
            """)
            str = str.replacingOccurrences(of: """
              return status == 0;
            """, with: """
              return fp != NULL;
            """)
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }

    override func frameworks() throws -> [String] {
        ["libshaderc_combined"]
    }

    override func build(platform: PlatformType, arch: ArchType, buildURL: URL) throws {
        try super.build(platform: platform, arch: arch, buildURL: buildURL)
        let thinDir = thinDir(platform: platform, arch: arch)
        let pkgconfig = thinDir + "lib/pkgconfig"
        try FileManager.default.moveItem(at: pkgconfig + "shaderc.pc", to: pkgconfig + "shaderc_shared.pc")
        try FileManager.default.moveItem(at: pkgconfig + "shaderc_combined.pc", to: pkgconfig + "shaderc.pc")
    }
}

class BuildLittleCms: BaseBuild {
    init() {
        super.init(library: .lcms2)
    }
}

class BuildDav1d: BaseBuild {
    init() {
        super.init(library: .libdav1d)
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        ["-Denable_asm=true", "-Denable_tools=false", "-Denable_examples=false", "-Denable_tests=false"]
    }
}

class BuildDovi: BaseBuild {
    init() {
        super.init(library: .libdovi)
    }
}
