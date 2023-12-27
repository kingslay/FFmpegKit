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
    }

    override func arguments(platform _: PlatformType, arch _: ArchType) -> [String] {
        [
            "-Dglib=disabled",
            "-Ddocs=disabled",
        ]
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
