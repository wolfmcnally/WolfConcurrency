Pod::Spec.new do |s|
    s.name             = 'WolfConcurrency'
    s.version          = '0.1.0'
    s.summary          = 'TODO: Summary'

    # s.description      = <<-DESC
    # TODO: Add long description of the pod here.
    # DESC

    s.homepage         = 'https://github.com/wolfmcnally/WolfConcurrency'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Wolf McNally' => 'wolf@wolfmcnally.com' }
    s.source           = { :git => 'https://github.com/wolfmcnally/WolfConcurrency.git', :tag => s.version.to_s }

    s.source_files = 'WolfConcurrency/Classes/**/*'

    s.swift_version = '4.2'

    s.ios.deployment_target = '10.0'
    s.macos.deployment_target = '10.13'
    s.tvos.deployment_target = '11.0'

    s.module_name = 'WolfConcurrency'

    s.dependency 'WolfLog'
    s.dependency 'WolfNumerics'
    s.dependency 'WolfFoundation'
end
