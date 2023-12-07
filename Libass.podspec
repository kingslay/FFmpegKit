Pod::Spec.new do |s|
    s.name             = 'Libass'
    s.version          = '0.17.1'
    s.summary          = 'Libass'

    s.description      = <<-DESC
    Libass
    DESC

    s.homepage         = 'https://github.com/kingslay/FFmpegKit'
    s.authors = { 'kintan' => '554398854@qq.com' }
    s.license          = 'MIT'
    s.source           = { :git => 'https://github.com/kingslay/FFmpegKit.git', :tag => s.version.to_s }

    s.ios.deployment_target = '13.0'
    s.osx.deployment_target = '10.15'
    # s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '13.0'
    s.default_subspec = 'Libass'
    s.static_framework = true
    s.subspec 'Libass' do |openssl|
        openssl.vendored_frameworks = 'Sources/libpng.xcframework', 'Sources/libfreetype.xcframework','Sources/libfribidi.xcframework', 'Sources/libharfbuzz.xcframework', 'Sources/libass.xcframework'
    end
end
