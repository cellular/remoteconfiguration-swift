source 'https://github.com/CocoaPods/Specs.git'

# Project Settings & Options
project 'CellularRemoteConfiguration'
use_frameworks!

# Remote Configuration
abstract_target 'RemoteConfiguration' do

    # Development related pods
    pod 'SwiftLint', :configuration => 'Debug'

    # Dependencies
    pod 'CELLULAR/Result', '~> 4.1'
    pod 'CellularNetworking', '~> 5.0'
    pod 'CellularLocalStorage', '~> 4.2'

    # Targets & Tests

    target 'RemoteConfiguration iOS' do
        platform :ios, '9.0'
        target 'RemoteConfiguration iOSTests' do
            inherit! :search_paths
        end
    end

    target 'RemoteConfiguration tvOS' do
        platform :tvos, '9.0'
        target 'RemoteConfiguration tvOSTests' do
            inherit! :search_paths
        end
    end

    target 'RemoteConfiguration watchOS' do
        platform :watchos, '2.0'
    end
end
