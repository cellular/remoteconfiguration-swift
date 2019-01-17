#!/bin/bash
gem install cocoapods --no-rdoc --no-ri --no-document --quiet;
pod repo remove master;
pod setup;
pod install;
