import Foundation
import UIKit

extension AppRouter {
    /// Current keyWindow rootViewController
    public class var rootViewController : UIViewController? {
        get { return AppRouter.window.rootViewController }
        set { AppRouter.window.rootViewController = newValue }
    }
    
    /// Current topmost controller
    public class var topViewController : UIViewController? {
        return topViewController()
    }
    
    /// Use this block to provide additional restrictions in topViewController algorithm.
    /// Can be helpful in rare cases, when unwanted controller is still in hierarchy (example: FBSDKContainerViewController).
    ///
    /// - returns: True - if topViewController algorithm should stop and use previous controller as top.
    public static var stopBlockForTopViewController: (UIViewController) -> Bool = { _ in return false }
    
    /// recursively tries to detect topmost controller
    /// - parameter startingFrom: Specify controller which will be used as start point for searching
    /// - returns: returns top-most controller if exists
    public class func topViewController(startingFrom base: UIViewController? = AppRouter.rootViewController) -> UIViewController? {
        if let base = base where stopBlockForTopViewController(base) { return nil }
        if let nav = base as? UINavigationController where !stopBlockForTopViewController(nav) {
            return topViewController(startingFrom: nav.visibleViewController) ?? nav
        }
        if let tab = base as? UITabBarController where !stopBlockForTopViewController(tab) {
            return topViewController(startingFrom: tab.selectedViewController) ?? tab
        }
        if let presented = base?.presentedViewController {
            return topViewController(startingFrom: presented) ?? base
        }
        return base
    }
}

extension UITabBarController {
    /// returns viewController of specified type if available
    ///
    /// - parameter type: Controller type
    /// - returns: one of viewControllers with specified type.
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
    /// returns viewController of specified type if available
    ///
    /// - parameter type: Controller type
    /// - returns: one of viewControllers with specified type.
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
    /// Easy way to detect if controller is modaly presented
    ///
    /// - returns: true - if controller or its navigationController / tabBarController is modaly presented
    public var isModal : Bool {
        return presentingViewController?.presentedViewController == self
            || navigationController?.isModal ?? false
            || tabBarController?.presentingViewController is UITabBarController
    }
}

