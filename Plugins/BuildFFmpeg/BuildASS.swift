//
//  BuildASS.swift
//
//
//  Created by kintan on 12/26/23.
//

import Foundation

class BuildFribidi: BaseBuild {
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

class BuildHarfbuzz: BaseBuild {
    init() {
        super.init(library: .libharfbuzz)
        let mesonBuild = directoryURL + "meson.build"
        if let data = FileManager.default.contents(atPath: mesonBuild.path),
           var str = String(data: data, encoding: .utf8)
        {
            // HarfBuzz 5.3.1 still probes freetype even when -Dfreetype=disabled.
            // Force-disable dependency to prevent hb-ft.cc from being compiled on iOS.
            let needle = """
if not freetype_dep.found()
  # Subproject fallback, `allow_fallback: true` means the fallback will be
  # tried even if the freetype option is set to `auto`.
  freetype_dep = dependency('freetype2',
                            required: get_option('freetype'),
                            default_options: ['harfbuzz=disabled'],
                            allow_fallback: true)
endif
"""
            let patch = """
if not freetype_dep.found()
  # Subproject fallback, `allow_fallback: true` means the fallback will be
  # tried even if the freetype option is set to `auto`.
  freetype_dep = dependency('freetype2',
                            required: get_option('freetype'),
                            default_options: ['harfbuzz=disabled'],
                            allow_fallback: true)
endif
if get_option('freetype').disabled()
  freetype_dep = disabler()
endif
"""
            if str.contains(needle) && !str.contains("freetype_dep = disabler()") {
                str = str.replacingOccurrences(of: needle, with: patch)
                try? str.write(toFile: mesonBuild.path, atomically: true, encoding: .utf8)
            }
        }
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        [
            "-Dglib=disabled",
            "-Dgobject=disabled",
            "-Ddocs=disabled",
            "-Dtests=disabled",
            "-Dintrospection=disabled",
            "-Dbenchmark=disabled",
            "-Dcairo=disabled",
            "-Dchafa=disabled",
            "-Dicu=disabled",
            "-Dfreetype=disabled",
            "-Dwerror=false",
        ]
    }

    override var isFramework: Bool {
        false
    }

    override func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        var env = super.environment(platform: platform, arch: arch)
        let extra = " -Wno-error=cast-function-type-strict"
        env["CFLAGS"] = (env["CFLAGS"] ?? "") + extra
        env["CXXFLAGS"] = (env["CXXFLAGS"] ?? "") + extra
        return env
    }
}

class BuildFreetype: BaseBuild {
    init() {
        super.init(library: .libfreetype)
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        [
            "-Dbrotli=disabled",
            "-Dharfbuzz=disabled",
            "-Dpng=disabled",
        ]
    }
}

class BuildPng: BaseBuild {
    init() {
        super.init(library: .libpng)
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        ["-DPNG_HARDWARE_OPTIMIZATIONS=yes"]
    }
}

class BuildASS: BaseBuild {
    init() {
        super.init(library: .libass)
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var result =
            [
                "--disable-libtool-lock",
                "--disable-fontconfig",
                "--disable-require-system-font-provider",
                "--disable-test",
                "--disable-profile",
                "--with-pic",
                "--enable-static",
                "--disable-shared",
                "--disable-fast-install",
                "--disable-dependency-tracking",
                "--host=\(platform.host(arch: arch))",
                "--prefix=\(thinDir(platform: platform, arch: arch).path)",
            ]
        if arch == .x86_64 {
            result.append("--enable-asm")
        }
        return result
    }
}
