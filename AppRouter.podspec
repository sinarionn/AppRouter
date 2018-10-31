
Pod::Spec.new do |s|
  s.name         = "AppRouter"
  s.version      = "6.0.0"
  s.summary      = "UIViewController creation, navigation, utility methods for easy routing"

  s.homepage     = "https://github.com/MLSDev/AppRouter"
  s.license      = "MIT"
  s.author       = { "Artem Antihevich" => "sinarionn@gmail.com" }
  s.social_media_url = 'https://twitter.com/sinarionn'

  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/MLSDev/AppRouter.git", :tag => s.version.to_s }
  s.requires_arc = true

  s.default_subspec = 'Core'
  s.ios.frameworks = 'UIKit', 'Foundation'

  s.subspec 'Core' do |core|
      core.source_files = 'Sources/Core/*.swift'
      core.ios.deployment_target = "9.0"
      core.dependency 'AppRouterLight'
  end

end
