SHELL := /bin/bash
# Install Tasks


install-iOS:
	xcrun instruments -w "iPhone SE" || true

install-carthage:
	brew remove carthage --force || true
	brew install carthage

install-cocoapods:
	gem install cocoapods --pre --no-rdoc --no-ri --no-document --quiet


test-iOS:
	set -o pipefail && xcodebuild -project AppRouter.xcodeproj -scheme TestApp -destination "name=iPhone SE" -enableCodeCoverage YES test -configuration "Debug" | xcpretty -ct
	bash <(curl -s https://codecov.io/bash)

test-carthage:
	carthage build --no-skip-current --platform iOS
	ls Carthage/build/iOS/AppRouter.framework

test-cocoapods:
	pod lib lint AppRouter.podspec --verbose
