
Pod::Spec.new do |s|
  s.name         = "AppRouter"
  s.version      = "4.1.1"
  s.summary      = "UIViewController creation, navigation, utility methods for easy routing"

  s.homepage     = "https://github.com/MLSDev/AppRouter"
  s.license      = "MIT"
  s.author       = { "Artem Antihevich" => "sinarionn@gmail.com" }
  s.social_media_url = 'https://twitter.com/sinarionn'

  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/MLSDev/AppRouter.git", :tag => s.version.to_s }
  s.requires_arc = true

  s.default_subspec = 'Core'
  s.ios.frameworks = 'UIKit', 'Foundation'

  s.subspec 'Core' do |core|
      core.source_files = 'Sources/Core/*.swift'
  end

  s.subspec 'RxSwift' do |rxswift|
      rxswift.osx.deployment_target = "10.10"
      rxswift.dependency 'RxSwift', '~> 4.0'
      rxswift.source_files = 'Sources/RxSwift/*.swift'
  end
end
