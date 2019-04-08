Pod::Spec.new do |s|
    s.name             = 'WolfConcurrency'
    s.version          = '3.0.1'
    s.summary          = 'Swift tools and conveniences for concurrency.'

    s.homepage         = 'https://github.com/wolfmcnally/WolfConcurrency'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Wolf McNally' => 'wolf@wolfmcnally.com' }
    s.source           = { :git => 'https://github.com/wolfmcnally/WolfConcurrency.git', :tag => s.version.to_s }

    s.source_files = 'WolfConcurrency/Classes/**/*'

    s.swift_version = '5.0'

    s.ios.deployment_target = '9.3'
    s.macos.deployment_target = '10.13'
    s.tvos.deployment_target = '11.0'

    s.module_name = 'WolfConcurrency'

    s.dependency 'WolfNumerics'
    s.dependency 'WolfFoundation'
end
