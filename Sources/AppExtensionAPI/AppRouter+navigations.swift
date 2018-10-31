import Foundation
import UIKit

/// Additional abilities to close / dismiss/ pop controllers
extension UIViewController {
    /// Pop to previous controller in navigation stack. Do nothing if current is first
    ///
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully.
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    @discardableResult
    public func pop(animated: Bool = true, completion: (()->())? = nil) -> [UIViewController]? {
        guard let stack = navigationController?.viewControllers , stack.count > 1 else {
            print("#[AppRouter] can't pop \"\(String(describing: self))\" when only one controller in navigation stack!")
            return nil
        }
        guard let first = stack.first , first != self else {
            print("#[AppRouter] can't pop from \"\(String(describing: self))\" because it's first in stack!")
            return nil
        }
        var previousViewController = first
        for controller in stack {
            if controller == self {
                return navigationController?.popToViewController(previousViewController, animated: animated, completion: completion)
            } else {
                previousViewController = controller
            }
        }
        return nil
    }
    
    /// Pop to previous controller in navigation stack. Do nothing if current is first
    ///
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully.
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    @discardableResult
    public func pop(completion: (()->())?) -> [UIViewController]? {
        return pop(animated: true, completion: completion)
    }
    
    /// Pop to previous controller in navigation stack. Do nothing if current is first
    ///
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    @discardableResult
    public func pop() -> [UIViewController]? {
        return pop(animated: true)
    }

    /// Tries to close viewController by popping to previous in navigation stack or by dismissing if presented
    ///
    /// - parameter animated: If true - transition animated
    /// - parameter completion: Called after transition ends successfully
    /// - returns: returns true if able to close
    @discardableResult
    public func close(animated: Bool, completion: (()->())? = nil) -> Bool {
        if canPop() {
            _ = pop(animated: animated, completion: completion)
        } else if isModal {
            dismiss(animated: animated, completion: completion)
        } else {
            print("#[AppRouter] can't close \"\(String(describing: self))\".")
            return false
        }
        return true
    }
    
    /// Tries to close viewController by popping to previous in navigation stack or by dismissing if presented
    ///
    /// - parameter completion: Called after transition ends successfully
    /// - returns: returns true if able to close
    @discardableResult
    public func close(completion: (()->())?) -> Bool {
        return close(animated: true, completion: completion)
    }
    
    /// Tries to close viewController by popping to previous in navigation stack or by dismissing if presented
    ///
    /// - returns: returns true if able to close
    @discardableResult
    public func close() -> Bool {
        return close(animated: true, completion: nil)
    }
    
    fileprivate func canPop() -> Bool {
        guard let stack = navigationController?.viewControllers , stack.count > 1 else { return false }
        guard let first = stack.first , first != self else { return false }
        return stack.contains(self)
    }
}

extension UITabBarController {
    /// Tries to find controller of specified type and make it selectedViewController
    ///
    /// - parameter type: required controller type
    /// - returns: True if changed successfully
    @discardableResult
    public func setSelectedViewController<T: UIViewController>(_ type: T.Type) -> Bool {
        if let controller = self.getControllerInstance(T.self) {
            if self.viewControllers?.contains(controller) ?? false {
                self.selectedViewController = controller
            } else if let navController = controller.navigationController , (self.viewControllers?.contains(navController) ?? false) {
                self.selectedViewController = navController
            }
            return true
        }
        return false
    }
}

extension UINavigationController {
    /// Pop to controller of specified type. Do nothing if current is first
    ///
    /// - parameter type: Required type
    /// - parameter animated: Set this value to true to animate the transition
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    @discardableResult
    public func popToViewController<T: UIViewController>(_ type: T.Type, animated: Bool) -> [UIViewController]? {
        guard let controller = self.getControllerInstance(T.self) else { return nil }
        return popToViewController(controller, animated: animated)
    }
}

/// Provides callback to standart UINavigationController methods
extension UINavigationController {
    /// Adds completion block to standart pushViewController(_, animated:) method
    ///
    /// - parameter viewController: controller to be pushed
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (()->())?) {
        guard !viewControllers.contains(viewController) else { return print("#[AppRouter] can't push \"\(String(describing: type(of: viewController)))\", already in navigation stack!") }
        pushViewController(viewController, animated: animated)
        _сoordinator(animated, completion: completion)
    }
    
    /// Adds completion block to standart popViewControllerAnimated method
    ///
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    /// - returns: the popped controller
    @discardableResult
    public func popViewController(animated: Bool, completion: (()->())?) -> UIViewController? {
        guard let popped = self.popViewController(animated: animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    /// Adds completion block to standart popToViewController(_, animated:) method
    ///
    /// - parameter viewController: pops view controllers until the one specified is on top
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    @discardableResult
    public func popToViewController(_ viewController: UIViewController, animated: Bool, completion: (()->())?) -> [UIViewController]? {
        guard let popped = popToViewController(viewController, animated: animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }

    /// Allow to pop to controller with specified type
    ///
    /// - parameter type: pops view controllers until the one with specified type is on top
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    @discardableResult
    public func popToViewController<T: UIViewController>(_ type: T.Type, animated: Bool, completion: (()->())?) -> [UIViewController]? {
        guard let popped = popToViewController(type, animated: animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    /// Adds completion block to standart popToRootViewControllerAnimated method
    ///
    /// - parameter animated: Set this value to true to animate the transition
    /// - parameter completion: Called after transition ends successfully
    /// - returns: [UIViewCotnroller]? - returns the popped controllers
    @discardableResult
    public func popToRootViewController(animated: Bool, completion: (()->())?) -> [UIViewController]? {
        guard let popped = self.popToRootViewController(animated: animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    fileprivate func _сoordinator(_ animated: Bool, completion: (()->())?) {
        if let coordinator = transitionCoordinator , animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
}
