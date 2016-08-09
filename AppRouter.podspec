
Pod::Spec.new do |s|
  s.name         = "AppRouter"
  s.version      = "0.1.0"
  s.summary      = "UIViewController creation, navigation, utility methods for easy routing"

  s.homepage     = "https://github.com/MLSDev/AppRouter"
  s.license      = "MIT"
  s.author             = { "Artem Antihevich" => "sinarionn@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/MLSDev/AppRouter.git", :tag => s.version.to_s }

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
      core.ios.frameworks = 'UIKit'
      core.source_files = 'Sources/Core/*.swift'
  end

  s.subspec 'RxSwift' do |rxswift|
      rxswift.dependency 'AppRouter/Core'
      rxswift.dependency 'RxSwift', '~> 2.6'
      rxswift.source_files = 'Sources/RxSwift/*.swift'
  end
end