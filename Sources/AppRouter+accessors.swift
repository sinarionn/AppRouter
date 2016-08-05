import Foundation
import UIKit

extension AppRouter {
    public class var rootViewController : UIViewController? {
        get { return AppRouter.window.rootViewController }
        set { AppRouter.window.rootViewController = newValue }
    }
    
    public class var topViewController : UIViewController? {
        return topViewController()
    }
    
    /**  - Parameter startingFrom: Specify controller which will be used as start point for searching
         - Returns: Returns top-most controller if exists */
    public class func topViewController(startingFrom base: UIViewController? = AppRouter.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(startingFrom: nav.visibleViewController) ?? nav
        }
        if let tab = base as? UITabBarController {
            return topViewController(startingFrom: tab.selectedViewController) ?? tab
        }
        if let presented = base?.presentedViewController {
            return topViewController(startingFrom: presented)
        }
        return base
    }
}

extension UITabBarController {
    public func getControllerInstance<T: UIViewController>(type: T.Type) -> T?{
        for controller in self.viewControllers ?? [] {
            if let reqController = controller as? T {
                return reqController
            } else if let navController = controller as? UINavigationController {
                if let reqController = navController.viewControllers.first as? T {
                    return reqController
                }
            }
        }
        return nil
    }
}

extension UINavigationController {
    public func getControllerInstance<T: UIViewController>(type: T.Type) -> T?{
        for controller in self.viewControllers {
            if let reqController = controller as? T {
                return reqController
            }
        }
        return nil
    }
}

extension UIViewController {
    /** Returns true - if controller or its navigationController / tabBarController is modaly presented */
    public var isModal : Bool {
        return presentingViewController?.presentedViewController == self
            || navigationController?.isModal ?? false
            || tabBarController?.presentingViewController is UITabBarController
    }
}

