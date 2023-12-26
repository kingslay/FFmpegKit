//
//  BuildMPV.swift
//
//
//  Created by kintan on 12/26/23.
//

import Foundation

class BuildMPV: BaseBuild {
    init() {
        super.init(library: .libmpv)
        let path = directoryURL + "meson.build"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: "# ffmpeg", with: """
            add_languages('objc')
            #ffmpeg
            """)
            str = str.replacingOccurrences(of: """
            subprocess_source = files('osdep/subprocess-posix.c')
            """, with: """
            if host_machine.subsystem() == 'tvos' or host_machine.subsystem() == 'tvos-simulator'
                subprocess_source = files('osdep/subprocess-dummy.c')
            else
                subprocess_source =files('osdep/subprocess-posix.c')
            endif
            """)
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }

    override func flagsDependencelibrarys() -> [Library] {
        [.gmp, .libsmbclient]
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var array = [
            "-Dlibmpv=true",
            "-Dgl=enabled",
            "-Dplain-gl=enabled",
            "-Diconv=enabled",
        ]
        if !(platform == .macos && arch.executable) {
            array.append("-Dcplayer=false")
        }
        if platform == .macos {
            array.append("-Dswift-flags=-sdk \(platform.isysroot) -target \(platform.deploymentTarget(arch: arch))")
            array.append("-Dcocoa=enabled")
            array.append("-Dcoreaudio=enabled")
            array.append("-Dgl-cocoa=enabled")
            array.append("-Dvideotoolbox-gl=enabled")
        } else {
            array.append("-Dvideotoolbox-gl=disabled")
            array.append("-Dswift-build=disabled")
            array.append("-Daudiounit=enabled")
            if platform == .maccatalyst {
                array.append("-Dcocoa=disabled")
                array.append("-Dcoreaudio=disabled")
            } else if platform == .xros || platform == .xrsimulator {
                array.append("-Dios-gl=disabled")
            } else {
                array.append("-Dios-gl=enabled")
            }
        }
        return array
    }
}
