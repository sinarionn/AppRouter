import Foundation
import UIKit

extension AppRouter {
    public class func popFromTopNavigation(animated animated: Bool = true, completion: Action? = nil) {
        topViewController()?.navigationController?.popViewController(animated, completion: completion)
    }
}

extension UIViewController {
    /** Pop to previous controller in navigation stack. Do nothing if current is first.
     - Parameter animated: Set this value to true to animate the transition.
     - Parameter completion: Called after transition ends successfully. */
    public func pop(animated animated: Bool = true, completion: Action? = nil) -> [UIViewController]? {
        guard let stack = navigationController?.viewControllers where stack.count > 1 else {
            AppRouter.print("#[AppRouter] can't pop \"\(String(self))\" when only one controller in navigation stack!")
            return nil
        }
        guard let first = stack.first where first != self else {
            AppRouter.print("#[AppRouter] can't pop from \"\(String(self))\" because it's first in stack!")
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

    /** Tries to close viewController by popping to previous in navigation stack or by dismissing */
    public func close(animated animated: Bool = true, completion: Action? = nil) -> Bool {
        if canPop() {
            pop(animated: animated, completion: completion)
        } else if isModal {
            dismissViewControllerAnimated(animated, completion: completion)
        } else {
            AppRouter.print("#[AppRouter] can't close \"\(String(self))\".")
            return false
        }
        return true
    }
    
    private func canPop() -> Bool {
        guard let stack = navigationController?.viewControllers where stack.count > 1 else { return false }
        guard let first = stack.first where first != self else { return false }
        return stack.contains(self)
    }
}

extension UITabBarController {
    public func setSelectedViewController<T: UIViewController>(type: T.Type) -> Bool {
        if let controller = self.getControllerInstance(T) {
            if self.viewControllers?.contains(controller) ?? false {
                self.selectedViewController = controller
            } else if let navController = controller.navigationController where (self.viewControllers?.contains(navController) ?? false) {
                self.selectedViewController = navController
            }
            return true
        }
        return false
    }
}

extension UINavigationController {
    public func popToViewController<T: UIViewController>(type: T.Type, animated: Bool) -> [UIViewController]? {
        guard let controller = self.getControllerInstance(T) else { return nil }
        return popToViewController(controller, animated: animated)
    }
}

extension UINavigationController {
    public func pushViewController(viewController: UIViewController, animated: Bool, completion: Action?) {
        guard !viewControllers.contains(viewController) else { return }
        pushViewController(viewController, animated: animated)
        _сoordinator(animated, completion: completion)
    }
    
    public func popViewController(animated: Bool, completion: Action?) -> UIViewController? {
        guard let popped = popViewControllerAnimated(animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    public func popToViewController(viewController: UIViewController, animated: Bool, completion: Action?) -> [UIViewController]? {
        guard let popped = popToViewController(viewController, animated: animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }

    public func popToViewController<T: UIViewController>(type: T.Type, animated: Bool, completion: Action?) -> [UIViewController]? {
        guard let popped = popToViewController(type, animated: animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    public func popToRootViewControllerAnimated(animated: Bool, completion: Action?) -> [UIViewController]? {
        guard let popped = popToRootViewControllerAnimated(animated) else { return nil }
        _сoordinator(animated, completion: completion)
        return popped
    }
    
    private func _сoordinator(animated: Bool, completion: Action?) {
        if let coordinator = transitionCoordinator() where animated {
            coordinator.animateAlongsideTransition(nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
}