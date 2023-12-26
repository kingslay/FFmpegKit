//
//  SSL.swift
//
//
//  Created by kintan on 12/26/23.
//

import Foundation

class BuildOpenSSL: BaseBuild {
    init() {
        super.init(library: .openssl)
    }

    override func frameworks() throws -> [String] {
        ["libssl", "libcrypto"]
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var array = [
            "--prefix=\(thinDir(platform: platform, arch: arch).path)",
            "no-async", "no-shared", "no-dso", "no-engine", "no-tests",
            arch == .x86_64 ? "darwin64-x86_64" : arch == .arm64e ? "iphoneos-cross" : "darwin64-arm64",
        ]
        if [PlatformType.tvos, .tvsimulator, .watchos, .watchsimulator].contains(platform) {
            array.append("-DHAVE_FORK=0")
        }
        return array
    }
}

class BuildBoringSSL: BaseBuild {
    init() {
        super.init(library: .boringssl)
        if Utility.shell("which go") == nil {
            Utility.shell("brew install go")
        }
    }
}

class BuildLibreSSL: BaseBuild {
    init() {
        super.init(library: .libtls)
    }

    override func cFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var cFlags = super.cFlags(platform: platform, arch: arch)
        if [PlatformType.tvos, .tvsimulator, .watchos, .watchsimulator].contains(platform) {
            cFlags.append("-DOPENSSL_NO_SPEED=1")
        }
        return cFlags
    }

    override func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        var env = super.environment(platform: platform, arch: arch)
        if [PlatformType.tvos, .tvsimulator, .watchos, .watchsimulator].contains(platform) {
            env["CFLAGS"]? += " -DOPENSSL_NO_SPEED=1"
        }
        return env
    }
}
