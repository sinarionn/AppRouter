
Pod::Spec.new do |s|
  s.name         = "AppRouter"
  s.version      = "4.0.1"
  s.summary      = "UIViewController creation, navigation, utility methods for easy routing"

  s.homepage     = "https://github.com/MLSDev/AppRouter"
  s.license      = "MIT"
  s.author       = { "Artem Antihevich" => "sinarionn@gmail.com" }
  s.social_media_url = 'https://twitter.com/sinarionn'

  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/MLSDev/AppRouter.git", :tag => s.version.to_s }
  s.requires_arc = true

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
      core.ios.frameworks = 'UIKit', 'Foundation'
      core.source_files = 'Sources/Core/*.swift'
  end

  s.subspec 'RxSwift' do |rxswift|
      rxswift.dependency 'AppRouter/Core'
      rxswift.dependency 'RxSwift', '~> 3.0'
      rxswift.source_files = 'Sources/RxSwift/*.swift'
  end
end
