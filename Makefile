SHELL := /bin/bash
# Install Tasks

install-iOS:
	true

install-carthage:
	brew rm carthage || true
	brew install carthage

install-coverage:
	true

install-cocoapods:
	true

# install-oss-osx:
# 	sh swiftenv-install.sh

# Run Tasks

test-iOS:
	set -o pipefail && \
		xcodebuild \
		-project AppRouter.xcodeproj \
		-scheme AppRouter \
		-destination "name=iPhone 6s" \
		clean test \
		| xcpretty -ct

test-carthage:
	carthage build --no-skip-current
	ls Carthage/build/iOS/AppRouter.framework

test-coverage:
	  set -o pipefail && xcodebuild -project AppRouter.xcodeproj -scheme AppRouter -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1' -enableCodeCoverage YES test | xcpretty -ct
		bash <(curl -s https://codecov.io/bash)

test-cocoapods:
	pod lib lint AppRouter.podspec --verbose

# test-oss-osx:
# 	. ~/.swiftenv/init && swift build
