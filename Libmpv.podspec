Pod::Spec.new do |s|
    s.name             = 'Libmpv'
    s.version          = '0.37.0'
    s.summary          = 'Libmpv'

    s.description      = <<-DESC
    Libmpv
    DESC

    s.homepage         = 'https://github.com/kingslay/FFmpegKit'
    s.authors = { 'kintan' => '554398854@qq.com' }
    s.license          = 'MIT'
    s.source           = { :git => 'https://github.com/kingslay/FFmpegKit.git', :tag => s.version.to_s }

    s.ios.deployment_target = '13.0'
    s.osx.deployment_target = '10.15'
    # s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '13.0'
    s.default_subspec = 'Libmpv'
    s.static_framework = true
    s.subspec 'Libmpv' do |mpv|
        mpv.vendored_frameworks = 'Sources/libmpv.xcframework'
        mpv.dependency 'FFmpegKit'
    end
end
