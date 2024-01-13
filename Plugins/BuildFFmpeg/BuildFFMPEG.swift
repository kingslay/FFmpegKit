//
//  BuildFFMPEG.swift
//
//
//  Created by kintan on 12/26/23.
//

import Foundation

class BuildFFMPEG: BaseBuild {
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

    override func flagsDependencelibrarys() -> [Library] {
        [.gmp, .nettle, .gnutls, .libsmbclient]
    }

    override func frameworks() throws -> [String] {
        var frameworks: [String] = []
        if let platform = platforms().first {
            if let arch = platform.architectures.first {
                let lib = thinDir(platform: platform, arch: arch) + "lib"
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: lib.path)
                for fileName in fileNames {
                    if fileName.hasPrefix("lib"), fileName.hasSuffix(".a") {
                        // 因为其他库也可能引入libavformat,所以把lib改成大写，这样就可以排在前面，覆盖别的库。
                        frameworks.append("Lib" + fileName.dropFirst(3).dropLast(2))
                    }
                }
            }
        }
        return frameworks
    }

    override func ldFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var ldFlags = super.ldFlags(platform: platform, arch: arch)
        ldFlags.append("-lc++")
        return ldFlags
    }

    override func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        var env = super.environment(platform: platform, arch: arch)
        env["CPPFLAGS"] = env["CFLAGS"]
        return env
    }

    override func build(platform: PlatformType, arch: ArchType, buildURL: URL) throws {
        try super.build(platform: platform, arch: arch, buildURL: buildURL)
        let prefix = thinDir(platform: platform, arch: arch)
        let lldbFile = URL.currentDirectory + "LLDBInitFile"
        if let data = FileManager.default.contents(atPath: lldbFile.path), var str = String(data: data, encoding: .utf8) {
            str.append("settings \(str.isEmpty ? "set" : "append") target.source-map \((buildURL + "src").path) \(directoryURL.path)\n")
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
        if platform == .macos, arch.executable {
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
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: "/usr/local/bin/ffmpeg"))
            try? FileManager.default.copyItem(at: prefix + "ffmpeg", to: URL(fileURLWithPath: "/usr/local/bin/ffmpeg"))
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: "/usr/local/bin/ffplay"))
            try? FileManager.default.copyItem(at: prefix + "ffplay", to: URL(fileURLWithPath: "/usr/local/bin/ffplay"))
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: "/usr/local/bin/ffprobe"))
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
        var arguments = [
            "--prefix=\(thinDir(platform: platform, arch: arch).path)",
        ]
        arguments += ffmpegConfiguers
        arguments += Build.ffmpegConfiguers
        arguments.append("--arch=\(arch.cpuFamily)")
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
            arguments.append("--enable-filter=scale_vt")
            arguments.append("--enable-filter=transpose_vt")
        }
        if platform == .macos, arch.executable {
            arguments.append("--enable-ffplay")
            arguments.append("--enable-sdl2")
            arguments.append("--enable-decoder=rawvideo")
            arguments.append("--enable-filter=color")
            arguments.append("--enable-filter=lut")
            arguments.append("--enable-filter=testsrc")
            arguments.append("--disable-avdevice")
            // debug
            arguments.append("--enable-debug")
            arguments.append("--enable-debug=3")
            arguments.append("--disable-stripping")
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
                if library == .libsrt || library == .libsmbclient {
                    arguments.append("--enable-protocol=\(library.rawValue)")
                } else if library == .libdav1d {
                    arguments.append("--enable-decoder=\(library.rawValue)")
                } else if library == .libass {
                    arguments.append("--enable-filter=ass")
                    arguments.append("--enable-filter=subtitles")
                } else if library == .libzvbi {
                    arguments.append("--enable-decoder=libzvbi_teletext")
                } else if library == .libplacebo {
                    arguments.append("--enable-filter=libplacebo")
                }
            }
        }
        return arguments
    }

    private let ffmpegConfiguers = [
        // Configuration options:
        "--disable-armv5te", "--disable-armv6", "--disable-armv6t2",
        "--disable-bzlib", "--disable-gray", "--disable-iconv", "--disable-linux-perf",
        "--disable-shared", "--disable-small", "--disable-swscale-alpha", "--disable-symver", "--disable-xlib",
        "--enable-cross-compile", "--enable-gpl", "--enable-libxml2", "--enable-nonfree",
        "--enable-optimizations", "--enable-pic", "--enable-runtime-cpudetect", "--enable-static", "--enable-thumb", "--enable-version3",
        "--pkg-config-flags=--static",
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
        "--enable-muxer=flac", "--enable-muxer=dash", "--enable-muxer=hevc",
        "--enable-muxer=m4v", "--enable-muxer=matroska", "--enable-muxer=mov", "--enable-muxer=mp4",
        "--enable-muxer=mpegts", "--enable-muxer=webm*",
        "--enable-muxer=nut",
        // ./configure --list-encoders
        "--disable-encoders",
        "--enable-encoder=aac", "--enable-encoder=alac", "--enable-encoder=flac", "--enable-encoder=pcm*",
        "--enable-encoder=movtext", "--enable-encoder=mpeg4", "--enable-encoder=h264_videotoolbox",
        "--enable-encoder=hevc_videotoolbox", "--enable-encoder=prores", "--enable-encoder=prores_videotoolbox",
        // ./configure --list-protocols
        "--enable-protocols",
        // ./configure --list-demuxers
        // 用所有的demuxers的话，那avformat就会达到8MB了，指定的话，那就只要4MB。
        "--disable-demuxers",
        "--enable-demuxer=aac", "--enable-demuxer=ac3", "--enable-demuxer=aiff", "--enable-demuxer=amr",
        "--enable-demuxer=ape", "--enable-demuxer=asf", "--enable-demuxer=ass", "--enable-demuxer=av1",
        "--enable-demuxer=avi", "--enable-demuxer=caf", "--enable-demuxer=concat",
        "--enable-demuxer=dash", "--enable-demuxer=data", "--enable-demuxer=dv",
        "--enable-demuxer=eac3",
        "--enable-demuxer=flac", "--enable-demuxer=flv", "--enable-demuxer=h264", "--enable-demuxer=hevc",
        "--enable-demuxer=hls", "--enable-demuxer=live_flv", "--enable-demuxer=loas", "--enable-demuxer=m4v",
        // matroska=mkv,mka,mks,mk3d
        "--enable-demuxer=matroska", "--enable-demuxer=mov", "--enable-demuxer=mp3", "--enable-demuxer=mpeg*",
        "--enable-demuxer=nut",
        "--enable-demuxer=ogg", "--enable-demuxer=rm", "--enable-demuxer=rtsp", "--enable-demuxer=rtp", "--enable-demuxer=srt",
        "--enable-demuxer=vc1", "--enable-demuxer=wav", "--enable-demuxer=webm_dash_manifest",
        // ./configure --list-bsfs
        "--enable-bsfs",
        // ./configure --list-decoders
        // 用所有的decoders的话，那avcodec就会达到40MB了，指定的话，那就只要20MB。
        "--disable-decoders",
        // 视频
        "--enable-decoder=av1", "--enable-decoder=dca", "--enable-decoder=dxv",
        "--enable-decoder=ffv1", "--enable-decoder=ffvhuff", "--enable-decoder=flv",
        "--enable-decoder=h263", "--enable-decoder=h263i", "--enable-decoder=h263p", "--enable-decoder=h264",
        "--enable-decoder=hap", "--enable-decoder=hevc", "--enable-decoder=huffyuv",
        "--enable-decoder=indeo5",
        "--enable-decoder=mjpeg", "--enable-decoder=mjpegb", "--enable-decoder=mpeg*", "--enable-decoder=mts2",
        "--enable-decoder=prores",
        "--enable-decoder=rv10", "--enable-decoder=rv20", "--enable-decoder=rv30", "--enable-decoder=rv40",
        "--enable-decoder=snow", "--enable-decoder=svq3",
        "--enable-decoder=tscc", "--enable-decoder=txd",
        "--enable-decoder=wmv1", "--enable-decoder=wmv2", "--enable-decoder=wmv3",
        "--enable-decoder=vc1", "--enable-decoder=vp6", "--enable-decoder=vp6a", "--enable-decoder=vp6f",
        "--enable-decoder=vp7", "--enable-decoder=vp8", "--enable-decoder=vp9",
        // 音频
        "--enable-decoder=aac*", "--enable-decoder=ac3*", "--enable-decoder=adpcm*", "--enable-decoder=alac*",
        "--enable-decoder=amr*", "--enable-decoder=ape", "--enable-decoder=cook",
        "--enable-decoder=dca", "--enable-decoder=dolby_e", "--enable-decoder=eac3*", "--enable-decoder=flac",
        "--enable-decoder=mp1*", "--enable-decoder=mp2*", "--enable-decoder=mp3*", "--enable-decoder=opus",
        "--enable-decoder=pcm*", "--enable-decoder=sonic",
        "--enable-decoder=truehd", "--enable-decoder=tta", "--enable-decoder=vorbis", "--enable-decoder=wma*",
        // 字幕
        "--enable-decoder=ass", "--enable-decoder=ccaption", "--enable-decoder=dvbsub", "--enable-decoder=dvdsub",
        "--enable-decoder=mpl2", "--enable-decoder=movtext",
        "--enable-decoder=pgssub", "--enable-decoder=srt", "--enable-decoder=ssa", "--enable-decoder=subrip",
        "--enable-decoder=xsub", "--enable-decoder=webvtt",

        // ./configure --list-filters
        "--disable-filters",
        "--enable-filter=aformat", "--enable-filter=amix", "--enable-filter=anull", "--enable-filter=aresample",
        "--enable-filter=areverse", "--enable-filter=asetrate", "--enable-filter=atempo", "--enable-filter=atrim",
        "--enable-filter=bwdif", "--enable-filter=delogo",
        "--enable-filter=equalizer", "--enable-filter=estdif",
        "--enable-filter=firequalizer", "--enable-filter=format", "--enable-filter=fps",
        "--enable-filter=hflip", "--enable-filter=hwdownload", "--enable-filter=hwmap", "--enable-filter=hwupload",
        "--enable-filter=idet", "--enable-filter=lenscorrection", "--enable-filter=lut*", "--enable-filter=negate", "--enable-filter=null",
        "--enable-filter=overlay",
        "--enable-filter=palettegen", "--enable-filter=paletteuse", "--enable-filter=pan",
        "--enable-filter=rotate",
        "--enable-filter=scale", "--enable-filter=setpts", "--enable-filter=superequalizer",
        "--enable-filter=transpose", "--enable-filter=trim",
        "--enable-filter=vflip", "--enable-filter=volume",
        "--enable-filter=w3fdif",
        "--enable-filter=yadif",
        "--enable-filter=avgblur_vulkan", "--enable-filter=blend_vulkan", "--enable-filter=bwdif_vulkan",
        "--enable-filter=chromaber_vulkan", "--enable-filter=flip_vulkan", "--enable-filter=gblur_vulkan",
        "--enable-filter=hflip_vulkan", "--enable-filter=nlmeans_vulkan", "--enable-filter=overlay_vulkan",
        "--enable-filter=vflip_vulkan", "--enable-filter=xfade_vulkan",
    ]
}
