Pod::Spec.new do |spec|
    spec.version       = '8.0.3'
    spec.swift_version = '5.1'
    spec.module_name   = 'RemoteConfiguration'
    spec.name          = 'CellularRemoteConfiguration'
    spec.summary       = 'Dynamic configuration of iOS, tvOS or watchOS application using remote files.'
    spec.homepage      = 'http://www.cellular.de'
    spec.authors       = { 'CELLULAR GmbH' => 'office@cellular.de' }
    spec.license       = { :type => 'MIT', :file => 'LICENSE' }
    spec.source        = { :git => 'https://github.com/cellular/remoteconfiguration-swift.git', :tag => spec.version.to_s }

    # Deployment Targets
    spec.ios.deployment_target     = '11.0'
    spec.tvos.deployment_target    = '11.0'
    spec.watchos.deployment_target = '5.0'

    # Core Subspec
    spec.subspec 'Core' do |sub|
        sub.dependency 'CellularLocalStorage', '~> 6.0.0'
        sub.source_files = 'Sources/RemoteConfiguration/Core/**/*.swift'
    end

    # Convenience Subspec
    spec.subspec 'Convenience' do |sub|
        sub.dependency 'CellularRemoteConfiguration/Core'
        sub.source_files = 'Sources/RemoteConfiguration/Convenience/**/*.swift'
    end

    # Default Subspecs
    spec.default_subspecs = 'Core'
end
