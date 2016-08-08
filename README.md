![Build Status](https://travis-ci.org/sinarionn/AppRouter.svg?branch=master) &nbsp;
[![codecov.io](http://codecov.io/github/sinarionn/AppRouter/coverage.svg?branch=master)](http://codecov.io/github/sinarionn/AppRouter?branch=master)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/AppRouter/badge.png) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/AppRouter/badge.png) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![Packagist](https://img.shields.io/badge/license-MIT-blue.svg)]()

# AppRouter

Extremely easy way to handle controller creation / presentation / navigation and reduce coherence in project in general.

## Requirements

- iOS 8.0+
- Xcode 7.3+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate AppRouter into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'AppRouter'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate AppRouter into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "sinarionn/AppRouter"
```

## Examples

#### Presentations

Imagine that you want to present some controller and for this you need other controller to present on. Usual way forces us to pass controller through weak properties or to use delegation mechanic. We can avoid this situation and just call:

```swift
AppRouter.topViewController?.presentViewController(newOne, animated: true, completion: nil)
```  
or even
```swift
newOne.presenter().present()
```

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
    GridPictureGalleryController.presenter().fromStoryboard("GridPictureGallery").embedInNavigation().configure{
      $0.picturesRepresentation = pictures
    }.present()
  }
  static func openChangePasswordController() {
    ChangePasswordViewController.presenter().push()
  }
}
```

**Note:** framework by default uses name of your UIViewController subclass as storyboard identifier to find viewController in storyboard (using String(controllerType))

#### Completion handlers

In addition to presentation / dismissal completion blocks provided by UiKit, AppRouter provides you completion blocks for pushing/popping controllers onto navigation stack:

```swift
pushViewController(_, animated:, completion:)
popViewController(animated animated:, completion:)
popToViewController(_:, animated:, completion:)
popToRootViewController(animated animated:, completion:)
popToViewController<T: UIViewController>(_:, animated:, completion:)
```

#### Closing controller

Another possible scenario: feature controller that can be pushed or presented in different parts of application. Simplest way to make such controller gone (close button or etc) is to use close method. Just:
```swift
@IBAction func closeTapped(sender: UIButton!) {
  self.close()
}
```
And thats it. Method will try to detect the proper way to make controller gone.
