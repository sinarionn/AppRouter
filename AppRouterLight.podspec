
Pod::Spec.new do |s|
  s.name         = "AppRouterLight"
  s.version      = "6.0.0"
  s.summary      = "UIViewController creation, navigation, utility methods for easy routing"

  s.homepage     = "https://github.com/MLSDev/AppRouter"
  s.license      = "MIT"
  s.author       = { "Artem Antihevich" => "sinarionn@gmail.com" }
  s.social_media_url = 'https://twitter.com/sinarionn'

  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/MLSDev/AppRouter.git", :tag => s.version.to_s }
  s.requires_arc = true

  s.default_subspec = 'All'
  s.ios.frameworks = 'UIKit', 'Foundation'

  s.subspec 'AppExtensionAPI' do |ext|
      ext.source_files = 'Sources/AppExtensionAPI/*.swift'
      ext.ios.deployment_target = "9.0"
  end

  s.subspec 'Route' do |route|
      route.source_files = 'Sources/Route/AppRouter+route.swift'
      route.dependency 'AppRouterLight/AppExtensionAPI'
      route.dependency 'RxCocoa', '~> 4.0'
      route.dependency 'ReusableView', '~> 2.0'
      route.ios.deployment_target = "9.0"

      route.subspec 'Dip' do |dip|
          dip.source_files = 'Sources/Route/*.swift'
          dip.dependency 'Dip', '~> 7.0'
          dip.ios.deployment_target = "9.0"
      end
  end

  s.subspec 'RxSwift' do |rxswift|
      rxswift.ios.deployment_target = "9.0"
      rxswift.osx.deployment_target = "10.10"
      rxswift.dependency 'RxCocoa', '~> 4.0'
      rxswift.source_files = 'Sources/RxSwift/*.swift'
  end

  s.subspec 'All' do |all|
      all.ios.deployment_target = "9.0"
      all.osx.deployment_target = "10.10"
      all.dependency 'RxCocoa', '~> 4.0'
      all.dependency 'Dip', '~> 7.0'
      all.dependency 'ReusableView', '~> 2.0'
      all.source_files = 'Sources/AppExtensionAPI/*.swift', 'Sources/RxSwift/*.swift', 'Sources/Route/*.swift'
  end
end
