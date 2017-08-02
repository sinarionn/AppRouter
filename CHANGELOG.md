# Change Log

All notable changes to this project will be documented in this file.


## [4.0.0](https://github.com/MLSDev/AppRouter/releases/tag/3.0.2)

AppRouter and Presenter was refactored to provide additional flexibility  


## [3.0.3](https://github.com/MLSDev/AppRouter/releases/tag/3.0.2)

Fixed bug with UIViewController instantiation inside UINavigationController


## [3.0.2](https://github.com/MLSDev/AppRouter/releases/tag/3.0.2)

Small dependencies fix


## [3.0.1](https://github.com/MLSDev/AppRouter/releases/tag/3.0.1)

Typealias Action = () -> () was removed to avoid collisions with "Action" framework class names


## [3.0.0](https://github.com/MLSDev/AppRouter/releases/tag/3.0.0)

WARNING: From now on Presenters source provider will use storyboard initial controller by default instead of one with class name as StoryboardID.
Make sure you check all code with default instantiations or with .presenter().fromStoryboard("name")

All life circle observers was moved into Reactive namespace and can be accessed by calling instance.rx.onViewDidLoad() or Type.rx.onViewDidLoad()   


## [2.0.1](https://github.com/MLSDev/AppRouter/releases/tag/2.0.1)

Small visibility problems fixed


## [2.0.0](https://github.com/MLSDev/AppRouter/releases/tag/2.0.0)

Swift 3 Release. Xcode 8 required.


## [1.0.2](https://github.com/MLSDev/AppRouter/releases/tag/1.0.2)

## Bug fixes

AppRouter got init() to allow overriding


## [1.0.1](https://github.com/MLSDev/AppRouter/releases/tag/1.0.1)

## Bug fixes

Configuration block is now called only once when calling .presenter().provideEmbeddedSourceController()
