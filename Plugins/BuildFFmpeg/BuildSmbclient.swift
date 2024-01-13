//
//  BuildSmbclient.swift
//
//
//  Created by kintan on 12/26/23.
//

import Foundation

///
/// https://github.com/xbmc/xbmc/blob/8d852242b8fed6fc99132c5428e1c703970f7201/tools/depends/target/samba-gplv3/Makefile
class BuildSmbclient: BaseBuild {
    init() {
        super.init(library: .libsmbclient)
    }

    override func wafPath() -> String {
        "buildtools/bin/waf"
    }

    override func cFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var cFlags = super.cFlags(platform: platform, arch: arch)
        cFlags.append("-Wno-error=implicit-function-declaration")
        return cFlags
    }

    override func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        var env = super.environment(platform: platform, arch: arch)
        env["PATH"]? += (":" + (URL.currentDirectory + "../Plugins/BuildFFmpeg/\(library.rawValue)/bin").path + ":" + (directoryURL + "buildtools/bin").path)
        env["PYTHONHASHSEED"] = "1"
        env["WAF_MAKE"] = "1"
        return env
    }

    override func wafBuildArg() -> [String] {
        ["--targets=smbclient"]
    }

    override func wafInstallArg() -> [String] {
        ["--targets=smbclient"]
    }

    override func build(platform: PlatformType, arch: ArchType, buildURL: URL) throws {
        try super.build(platform: platform, arch: arch, buildURL: buildURL)
        try FileManager.default.copyItem(at: directoryURL + "bin/default/source3/libsmb/libsmbclient.a", to: thinDir(platform: platform, arch: arch) + "lib/libsmbclient.a")
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var arg =
            [
                "--without-cluster-support",
                "--disable-rpath",
                "--without-ldap",
                "--without-pam",
                "--enable-fhs",
                "--without-winbind",
                "--without-ads",
                "--disable-avahi",
                "--disable-cups",
                "--without-gettext",
                "--without-ad-dc",
                "--without-acl-support",
                "--without-utmp",
                "--disable-iprint",
                "--nopyc",
                "--nopyo",
                "--disable-python",
                "--disable-symbol-versions",
                "--without-json",
                "--without-libarchive",
                "--without-regedit",
                "--without-lttng",
                "--without-gpgme",
                "--disable-cephfs",
                "--disable-glusterfs",
                "--without-syslog",
                "--without-quotas",
                "--bundled-libraries=ALL",
                "--with-static-modules=!vfs_snapper,ALL",
                "--nonshared-binary=smbtorture,smbd/smbd,client/smbclient",
                "--builtin-libraries=!smbclient,!smbd_base,!smbstatus,ALL",
                "--host=\(platform.host(arch: arch))",
                "--prefix=\(thinDir(platform: platform, arch: arch).path)",
            ]
        arg.append("--cross-compile")
        arg.append("--cross-answers=cross-answers.txt")
        return arg
    }
}

class BuildReadline: BaseBuild {
    init() {
        super.init(library: .readline)
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        [
            "--enable-static",
            "--disable-shared",
            "--host=\(platform.host(arch: arch))",
            "--prefix=\(thinDir(platform: platform, arch: arch).path)",
        ]
    }
}

class BuildGmp: BaseBuild {
    init() {
        super.init(library: .gmp)
        if Utility.shell("which makeinfo") == nil {
            Utility.shell("brew install texinfo")
        }
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        [
            "--disable-maintainer-mode",
            "--disable-assembly",
            "--with-pic",
            "--enable-static",
            "--disable-shared",
            "--disable-fast-install",
            "--host=\(platform.host(arch: arch))",
            "--prefix=\(thinDir(platform: platform, arch: arch).path)",
        ]
    }
}

class BuildNettle: BaseBuild {
    init() {
        if Utility.shell("which autoconf") == nil {
            Utility.shell("brew install autoconf")
        }
        super.init(library: .nettle)
    }

    override func flagsDependencelibrarys() -> [Library] {
        [.gmp]
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        [
            "--disable-assembler",
            "--disable-openssl",
            "--disable-gcov",
            "--disable-documentation",
            "--enable-pic",
            "--enable-static",
            "--disable-shared",
            "--disable-dependency-tracking",
            "--host=\(platform.host(arch: arch))",
            "--prefix=\(thinDir(platform: platform, arch: arch).path)",
//                arch == .arm64 || arch == .arm64e ? "--enable-arm-neon" : "--enable-x86-aesni",
        ]
    }

    override func frameworks() throws -> [String] {
        [library.rawValue, "hogweed"]
    }
}

class BuildGnutls: BaseBuild {
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

    override func flagsDependencelibrarys() -> [Library] {
        [.gmp, .nettle]
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
        [
            "--with-included-libtasn1",
            "--with-included-unistring",
            "--without-brotli",
            "--without-idn",
            "--without-p11-kit",
            "--without-zlib",
            "--without-zstd",
            "--enable-hardware-acceleration",
            "--disable-openssl-compatibility",
            "--disable-code-coverage",
            "--disable-doc",
            "--disable-maintainer-mode",
            "--disable-manpages",
            "--disable-nls",
            "--disable-rpath",
//                "--disable-tests",
            "--disable-tools",
            "--disable-full-test-suite",
            "--with-pic",
            "--enable-static",
            "--disable-shared",
            "--disable-fast-install",
            "--disable-dependency-tracking",
            "--host=\(platform.host(arch: arch))",
            "--prefix=\(thinDir(platform: platform, arch: arch).path)",
        ]
    }
}
