Pod::Spec.new do |s|
    s.name             = 'OpenSSL'
    s.version          = '3.1.0'
    s.summary          = 'OpenSSL'

    s.description      = <<-DESC
    OpenSSL
    DESC

    s.homepage         = 'https://github.com/kingslay/FFmpegKit'
    s.authors = { 'kintan' => '554398854@qq.com' }
    s.license          = 'MIT'
    s.source           = { :git => 'https://github.com/kingslay/FFmpegKit.git', :tag => s.version.to_s }

    s.ios.deployment_target = '13.0'
    s.osx.deployment_target = '10.15'
    # s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '13.0'
    s.default_subspec = 'OpenSSL'
    s.static_framework = true
    s.subspec 'OpenSSL' do |openssl|
        openssl.vendored_frameworks = 'Sources/Libssl.xcframework', 'Sources/Libcrypto.xcframework'
    end
end
