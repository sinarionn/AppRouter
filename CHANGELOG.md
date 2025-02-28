# Change Log

All notable changes to this project will be documented in this file.

## [6.0.0](https://github.com/MLSDev/AppRouter/releases/tag/6.0.0)

SPM support added.


## [5.1.0](https://github.com/MLSDev/AppRouter/releases/tag/5.1.0)

XCode 10 and swift 4.2 fixes.


## [5.0.0](https://github.com/MLSDev/AppRouter/releases/tag/5.0.0)

New 'AppRouter/Route' subspec.
'AppRouter/RxSwift' methods uses Signal's instead of Observables.
Presenter methods (push, present, setAsRoot) becomes throwable instead of returning optionals.
New presenter configurable action called 'show'.
Presenter supports multiple configurations (by providing different labels alongside configuration block)


## [4.1.0](https://github.com/MLSDev/AppRouter/releases/tag/4.1.0)

Swift 4 migration.
MacOS support for RxSwift subspec
RxSwift subspec does not include Core automatically to allow usage in Cocoa applications.


## [4.0.2](https://github.com/MLSDev/AppRouter/releases/tag/4.0.2)

Swift 3.2 migration.


## [4.0.1](https://github.com/MLSDev/AppRouter/releases/tag/4.0.1)

Presenter namespace-enum changed into open class to prevent weird bug with overrides.


## [4.0.0](https://github.com/MLSDev/AppRouter/releases/tag/4.0.0)

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
