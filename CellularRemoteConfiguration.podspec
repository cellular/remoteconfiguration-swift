Pod::Spec.new do |spec|
    spec.version     = '5.0'
    spec.name        = 'CellularRemoteConfiguration'
    spec.summary     = 'Dynamic configuration of iOS, tvOS or watchOS application using remote files.'
    spec.homepage    = 'http://www.cellular.de'
    spec.authors     = { 'CELLULAR GmbH' => 'office@cellular.de' }
    spec.license     = { :type => 'MIT', :file => 'LICENSE' }
    spec.source      = { :git => 'https://github.com/cellular/remoteconfiguration-swift.git', :tag => spec.version.to_s }
    spec.module_name = 'RemoteConfiguration'
    spec.swift_version = '4.2'

    # Deployment Targets
    spec.ios.deployment_target     = '9.0'
    spec.tvos.deployment_target    = '9.0'
    spec.watchos.deployment_target = '2.0'

    # Core Subspec
    spec.subspec 'Core' do |sub|
        sub.dependency 'CELLULAR/Result', '~> 4.1'
        sub.dependency 'CellularLocalStorage', '~> 4.2'
        sub.source_files = 'Sources/RemoteConfiguration/Core/**/*.swift'
    end

    # Networking Subspec
    spec.subspec 'Networking' do |sub|
        sub.dependency 'CellularNetworking', '~> 5.0'
        sub.dependency 'CellularRemoteConfiguration/Core'
        sub.source_files = 'Sources/RemoteConfiguration/Networking/**/*.swift'
    end

    # Convenience Subspec
    spec.subspec 'Convenience' do |sub|
        sub.dependency 'CellularRemoteConfiguration/Core'
        sub.source_files = 'Sources/RemoteConfiguration/Convenience/**/*.swift'
    end

    # Default Subspecs
    spec.default_subspecs = 'Core', 'Networking'
end
