Pod::Spec.new do |s|
    s.name             = 'FFmpegKit'
    s.version          = '6.1.0'
    s.summary          = 'FFmpegKit'

    s.description      = <<-DESC
    FFmpeg
    DESC

    s.homepage         = 'https://github.com/kingslay/FFmpegKit'
    s.authors = { 'kintan' => '554398854@qq.com' }
    s.license          = 'MIT'
    s.source           = { :git => 'https://github.com/kingslay/FFmpegKit.git', :tag => s.version.to_s }

    s.ios.deployment_target = '13.0'
    s.osx.deployment_target = '10.15'
    # s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '13.0'
    s.default_subspec = 'FFmpegKit'
    s.static_framework = true
    s.source_files = 'Sources/FFmpegKit/**/*.{h,c,m}'
    s.subspec 'FFmpegKit' do |ffmpeg|
        ffmpeg.libraries   = 'bz2', 'c++', 'iconv', 'resolv', 'xml2', 'z'
        ffmpeg.vendored_frameworks = 'Sources/Libavcodec.xcframework','Sources/Libavfilter.xcframework','Sources/Libavformat.xcframework','Sources/Libavutil.xcframework','Sources/Libswresample.xcframework','Sources/Libswscale.xcframework', 
        'Sources/libshaderc_combined.xcframework','Sources/MoltenVK.xcframework', 'Sources/lcms2.xcframework', 'Sources/libdav1d.xcframework', 'Sources/libplacebo.xcframework',
        'Sources/gmp.xcframework', 'Sources/nettle.xcframework', 'Sources/hogweed.xcframework', 'Sources/gnutls.xcframework', 'Sources/libsmbclient.xcframework',
        'Sources/libzvbi.xcframework', 'Sources/libsrt.xcframework'
        ffmpeg.dependency 'Libass'
    end
end
