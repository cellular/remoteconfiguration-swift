#!/bin/bash
set -e; # Fail on first error

# Prepare
set -o pipefail; # xcpretty
xcodebuild -version;
xcodebuild -showsdks;

# Generate xcodeproj for building/testing
swift package generate-xcodeproj;

# Build Framework in Debug and Run Tests if specified
if [ "$RUN_TESTS" == "NO" ]; then
    xcodebuild -project RemoteConfiguration.xcodeproj -scheme RemoteConfiguration-Package -destination "$DESTINATION" -configuration Release ONLY_ACTIVE_ARCH=NO | xcpretty;
else
    xcodebuild test -project RemoteConfiguration.xcodeproj -scheme RemoteConfiguration-Package -destination "$DESTINATION" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES | xcpretty;
fi
# Run `pod lib lint` if specified
if [ "$POD_LINT" == "YES" ]; then
	gem install cocoapods --no-document --quiet;
    pod lib lint;
fi
