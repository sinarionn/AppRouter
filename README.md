![Build Status](https://travis-ci.org/sinarionn/AppRouter.svg?branch=master) &nbsp;
[![codecov.io](http://codecov.io/github/sinarionn/AppRouter/coverage.svg?branch=master)](http://codecov.io/github/sinarionn/AppRouter?branch=master)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/AppRouter/badge.png) &nbsp;
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/AppRouter/badge.png) &nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![Packagist](https://img.shields.io/badge/license-MIT-blue.svg)]()

# AppRouter
Provides bunch of methods for controller creation / managing / presentation

### Accessors:
###### AppRouter:
- class var **rootViewController** - returns current window rootViewController
- class var **topViewController** - returns topmost controller
- class func **topViewController(**base: UIViewController**)** - returns topmost controller starting from specified

###### UITabBarController:
- func **getControllerInstance(**Type**)** - returns instance with specified type from current viewControllers
- func **setSelectedViewController(**Type**)** - gets instance with specified type and makes it to be selectedViewController

###### UINavigationController:
- func **getControllerInstance(**Type**)** - returns instance with specified type from current viewControllers
- func **popToViewController(**Type**)** - tries to pop to viewController with specified type

###### UIViewController:
- class var **isModal** - returns true if controller or its navigation controller is modaly presented

### Instantiations:
###### UIViewController:
- class func **instantiate(**storyboardName, initial**)** - returns instance of current type created from storyboard with provided name or using String(self) as name.
- class func **instantiateInsideNavigation(**storyboardName, initial**)** - return navigationController created by class name or initial of specified if its first controller type == Self
- class func **instantiateFromXib(**xibName**)** - returns instance of current type created from xib with provided name or using String(self) as name.

###### UIStoryboard:
- func **instantiateViewController(**Type, initial**)** - instantiates controller using its class name as identifier or initial if specified. If instantiation returns UINavigationController - tries to use it first controller from stack
- func **instantiateViewControllerInsideNavigation(**Type, initial**)** - return navigationController created by class name or initial of specified if its first controller type == Type

### Navigations:
###### AppRouter:
- class func **popFromTopNavigation(**animated, completion**)** - pops topmost controller if it's embedded in navigation controller

###### UIViewController:
- func **pop(**animated, completion**)** - pops to previous controller in navigation stack. Do nothing if current is first or there no navigation controller. Returns array with controller which was popped.
- func **close(**animated, completion**)** - tries to close controller by popping to previous in navigation stack or by dismissing if modal.

###### UINavigationController:
- func **pushViewController(**animated, completion**)** - provides ability to specify completion block for standard pushViewController method. Completion called ONLY if push happens.
- func **popViewController(**animated, completion**)** - bunch of methods which provides completion block to standard popViewController methods. Completion called ONLY if pop happens.

### Presenter:
###### UIViewController:
- class func **presenter()** - return ViewControllerPresentConfiguration that can be used for configuring and presenting current type controller.
- func **presenter()** - return ViewControllerPresentConfiguration which uses current controller instance as source controller and can be used for configuring and presenting.

###### ViewControllerPresentConfiguration:
- var **target** - provides target on which presentation will be applied
- var **source** - provides controller which will be configured, embedded and presented
- var **embedder** - provides ability to embed source before presentation.
- var **configurator** - configure source before presentation


- func **onTop()** - declare AppRouter.topViewController to be a **target** provider
- func **onRoot()** - declare AppRouter.rootViewController to be a **target** provider
- func **onCustom(**targetBlock**)** - declare controller which will be returned by block as **target**


- func **fromStoryboard(**name, initial**)** - declare **source** provider to take controller from storyboard
- func **fromXib(**name**)** - declare **source** provider to take controller from xib


- func **configure(**configurator**)** - declare **configuration** block which used to configure controller before presentation


- func **embedInNavigation(**navigationController**)** - declare **embedder** provider to embed controller in a custom UINavigationController before presentation
- func **embedInTabBar(**tabBarController**)** - declare **embedder** provider to embed controller in UITabBarController before presentation
- func **embedIn(**embederBlock**)** - declare custom anonymous **embedder** provider


- func **push(**animated, completion**)** - takes controller from **source** provider, embeds it using **embedder** and push it on navigation controller provided by **target**
- func **present(**animated, completion**)** - takes controller from **source** provider, embeds it using **embedder** and present it on controller provided by **target**

- func **provideSourceController()** - takes controller from **source** provider and configures it using **configuration** block.
- func **provideEmbeddedSourceController()** - takes controller from **source** provider, configures it using **configuration** block, and embeds it using **embedder**


### Examples:
```
extension ViewControllerPresentConfiguration {
    func embedInYummiNavigation() -> ViewControllerPresentConfiguration {
        let navController = UINavigationController()
        navController.navigationBar.barTintColor = UIColor.grayColor()
        navController.navigationBar.translucent = false
        return self.embedInNavigation(navController)
    }
}

extension AppRouter {
    func presentGridPictureGalleryControllerWith(pictures: PicturesRepresentation) {
        GridPictureGalleryController.presenter().fromStoryboard("GridPictureGallery").embedInNavigation(AppRouter.defaultNavigationController().then {
            $0.navigationBar.tintColor = UIColor.whiteColor()
            $0.modalTransitionStyle = .CrossDissolve
        }).configure{ $0.picturesRepresentation = pictures }.present()
    }
    func presentChangePasswordController() {
        ChangePasswordViewController.presenter().push()
    }
    func presentExploreDetailsController(initialPostPicture: PostPicture?) {
        ExploreDetailsViewController.presenter().onRoot().configure{
          $0.postPicture = initialPostPicture
        }.embedInNavigation(AppRouter.defaultNavigationController().then {
              $0.modalTransitionStyle = .CrossDissolve
              $0.navigationBar.tintColor = .whiteColor()
        }).present()
    }
    func presentSearchController(startingFromTabIndex startingFrom : Int = 0, initialSearch : String = "") {
        SearchViewController.presenter().fromStoryboard("Search").onRoot().embedInYummiNavigation().configure{
            $0.startingTabIndex = startingFrom
            $0.initialSearch = initialSearch
        }.present()
    }   
}

```

### TODO:
Due to time limitations some functionality wasn't properly tested. Use it on your own risk.
Untested methods:
- UIViewController.isModal
- UIViewController.instantiateInsideNavigation
- UIViewController.pop(animated, completion)
- UINavigationController.pushViewController(animated, completion)
- UINavigationController.popViewController(animated, completion)
