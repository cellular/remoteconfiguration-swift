source 'https://github.com/CocoaPods/Specs.git'

# Project Settings & Options
project 'CellularRemoteConfiguration'
use_frameworks!

# Remote Configuration
abstract_target 'RemoteConfiguration' do

    # Development related pods
    pod 'SwiftLint', :configuration => 'Debug'

    # Dependencies
    pod 'CellularNetworking/Core', :git => 'git@github.com:markuswntr/networking-swift.git', :branch => 'master'
    pod 'CellularLocalStorage', '~> 5.0'

    # Targets & Tests

    target 'RemoteConfiguration iOS' do
        platform :ios, '10.3'
        target 'RemoteConfiguration iOSTests' do
            inherit! :search_paths
        end
    end

    target 'RemoteConfiguration tvOS' do
        platform :tvos, '10.2'
        target 'RemoteConfiguration tvOSTests' do
            inherit! :search_paths
        end
    end

    target 'RemoteConfiguration watchOS' do
        platform :watchos, '3.0'
    end
end

