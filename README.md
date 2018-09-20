![AppRouter Logo](/logo.png)


![Build Status](https://travis-ci.org/MLSDev/AppRouter.svg?branch=master) &nbsp;
[![codecov.io](http://codecov.io/github/MLSDev/AppRouter/coverage.svg?branch=master)](http://codecov.io/github/MLSDev/AppRouter?branch=master)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/AppRouter/badge.png) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/AppRouter/badge.png) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![Packagist](https://img.shields.io/badge/license-MIT-blue.svg)]()

Extremely easy way to handle controller creation / presentation / navigation and reduce coherence for project in general.

- [Requirements](#requirements)
- [Example](#example)
- [Installation](#installation)
- [Content](#content)
  - [Easy accessors](#easy-accessors)
  - [Easy controller construction/configuration/presentation](#easy-construction-configuration-presentation)
  - [Completion handlers](#completion-handlers)
  - [RxSwift extensions](#rxswift-extensions)

## Requirements

- iOS 8.0+
- macOS 10.10+ (RxSwift subspec only)
- Xcode 9+
- Swift 4


## Example

 `1.` You may need to set your root controller at application start, just:

 ```swift
 try? MainTabBarController.presenter().setAsRoot()
 ```

 `2.` And at some point - to present search controller:

 ```swift
 try? SearchController.presenter().embedInNavigation().present()
 ```

 `3.` And then you want to push controller with user selected product:

 ```swift
 try? ProductDetailsController.presenter().configure{
   $0.product = userSelectedProduct
 }.push()
 ```

 Example before assumes you are using separate Storyboards for each controller Type.

 **Note:** I recommend to have separate storyboards for each controller, so that for the each controller type you'll have separate folder with something like this:
 ```
 UIViewControllerType.storyboard
 UIViewControllerType.swift
 UIViewControllerTypeViewModel.swift
 UIViewControllerTypeViewModelTests.swift
 ```

 And don't forget to mark your controller in storyboard as `initial`, this will allow you to use Presenter default configurations.


## Installation

### CocoaPods

```ruby
pod 'AppRouter'
```

```ruby
pod 'AppRouter/Route'
```

RxSwift extension for AppRouter with life cycle observables:
**Warning:** RxSwift subspec does not include `Core` anymore.

```ruby
pod 'AppRouter'
pod 'AppRouter/RxSwift'
```

### Carthage

```ruby
github "MLSDev/AppRouter"
```

## Content

#### Easy accessors
```swift
// provides access to keyWindow (also creates one if current is nil)
AppRouter.window

// root controller in current window stack
AppRouter.rootViewController

// topmost controller
AppRouter.topViewController

// returns instance of passed type if its present in tabBar (even if it's embedded in navigationController)
tabBarController.getControllerInstance<T: UIViewController>(_:) -> T?

// returns instance of passed type if its present in navigationController
navigationController.getControllerInstance<T: UIViewController>(_:) -> T?

// returns true if current controller modally presented
viewController.isModal
```

#### Easy Construction, Configuration, Presentation

Of course it's always better to extract controller creation, configuration and presentation logic out of other controllers and views into FlowControllers or just simple extension methods (if you want this new controller work results - give them completion block or try using **reactive** ways). This will significantly reduce coherence and allow you to modify only one place in whole app to change logic behind feature :

```swift
extension AppRouter {
  static func openGridPictureGalleryControllerWith(pictures: PicturesRepresentation) {
    try? GridPictureGalleryController.presenter().fromStoryboard("GridPictureGallery").embedInNavigation().configure{
      $0.picturesRepresentation = pictures
    }.present()
  }
  static func openChangePasswordController() {
    try? ChangePasswordViewController.presenter().push()
  }
}
```

**Note:** framework by default uses name of your UIViewController subclass (String(describing: controllerType)) as storyboard identifier and initial controller (or rootViewController on initial UINavigationController)

In general - `presenter()` returns you configuration related to ViewController class it was called from.
This configuration allows you to specify how to create controller, what needs to be done before presentation, where resulting controller should be presented or pushed and so on.

All Configuration methods are documented, so read it before usage.
Few available methods:
##### Specifying source for the view controller:

`func fromStoryboard(_ name: String?, initial : Bool)` - will try to create controller from specified storyboard.

`func fromXib(_ name: String?)` - will try to create from Xib.

`func from(provider: @escaping () throws -> T)` - will create using provided factory method.

##### Specyfying destionation:

`func onTop()` - AppRouter.topViewController will be used as target.

`func onRoot()` - AppRouter.rootViewController will be used.

`func on(_ provider: @escaping () throws -> UIViewController)` - will use provided controller

**Note** that controller creation, target resolve and all other configuration steps will only be performed when `presentation methods` called (`push`, `present`, `setAsRoot`, `show`)

##### Should controller be embedded in something?

`func embedInNavigation(_ navigationController: @autoclosure @escaping () -> UINavigationController` - if you need to get controller inside UINavigationController.
`func embedIn(_ embederBlock: @escaping (T) throws -> UIViewController)` - if you need some custom embed rules.  

##### Additional configurations before performing present action:

`func configure(_ label: CustomStringConvertible, _ configuration: @escaping (T) throws -> ())` - can be used to additionally configure controller.

##### Showing controllers:

`func present()` - this action will build your controller from source you specified, embed it if needed, configure with your additional configurations, resolve target to present on, and... present.

`func push()` - same as previous, but needs target controller to be UINavigationController by itself or be inside one (UIViewController.navigationController property will be used). And pushes instead of presenting.

`func show()` - action totally handled by you (you can setup it through `handleShow` method)


#### Completion handlers

In addition to presentation / dismissal completion blocks provided by UiKit, AppRouter provides you completion blocks for pushing/popping controllers onto navigation stack:

```swift
pushViewController(_, animated:, completion:)
popViewController(animated animated:, completion:)
popToViewController(_:, animated:, completion:)
popToRootViewController(animated animated:, completion:)
popToViewController<T: UIViewController>(_:, animated:, completion:)
```

#### How to close controller?

Another possible scenario: feature controller that can be pushed or presented in different parts of application. Simplest way to make such controller gone (close button or etc) is to use close method. Just:
```swift
@IBAction func closeTapped(sender: UIButton!) {
  self.close()
}
```
And thats it. Method will try to detect the proper way to make controller disappear.

#### RxSwift extensions

If you want some easy way to deal with controller lifecycle outside - try to use AppRouter/RxSwift subspec. It provides a bunch of Type and Instance observables around lifecycle methods (it uses swizzling underneath from the moment you subscribe) :

```swift
instance.rx.onViewDidLoad() -> Signal<Void>
instance.rx.onViewWillAppear() -> Signal<Bool>
instance.rx.onViewDidAppear() -> Signal<Bool>
instance.rx.onViewWillDisappear() -> Signal<Bool>
instance.rx.onViewDidDisappear() -> Signal<Bool>

Type.rx.onViewDidLoad() -> Signal<Type>
Type.rx.onViewWillAppear() -> Signal<(controller: Type, animated: Bool)>
Type.rx.onViewDidAppear() -> Signal<(controller: Type, animated: Bool)>
Type.rx.onViewWillDisappear() -> Signal<(controller: Type, animated: Bool)>
Type.rx.onViewDidDisappear() -> Signal<(controller: Type, animated: Bool)>
```

#### Route subspec

Advanced Presenter.Configuration called 'Route' to use with Dip, ReusableView in mvvm world.
It provides an ability to resolve ViewController/ViewModel using viewModelFactory/viewFactory.


## Author

Artem Antihevich, sinarionn@gmail.com


## License

ReusableView is available under the MIT license. See the LICENSE file for more info.
