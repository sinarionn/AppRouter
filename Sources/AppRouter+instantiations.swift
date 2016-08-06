import Foundation
import UIKit

/// Workaround to use Self
public protocol BundleForClassInstantiable { }
extension UIViewController: BundleForClassInstantiable { }
extension BundleForClassInstantiable where Self : UIViewController {
    /// Instantiates controller from storyboard.
    ///
    /// - parameter storyboardName: storyboard name to be used, if nil - String(self) will be used
    /// - parameter initial: If true - instantiates initial viewController and if it's UINavigationController - tries to take it rootViewController. If no - instantiates viewController with identifier String(self)
    /// - returns: controller instance if everything is ok
    public static func instantiate(storyboardName storyboardName : String? = nil, initial : Bool = false) -> Self? {
        return UIStoryboard(storyboardName ?? String(self), bundle: NSBundle(forClass: self)).instantiateViewController(self, initial: initial)
    }
}

/// AppRouter utility methods for UIViewController
extension UIViewController {
    /// Instantiates controller from xib.
    ///
    /// - parameter xibName: xib name to be used, if nil - String(self) will be used
    /// - returns: controller instance if everything is ok
    public class func instantiateFromXib(xibName : String? = nil) -> Self? {
        return _instantiateFromXib(self, xibName: xibName ?? String(self))
    }
    
    private class func _instantiateFromXib<T : UIViewController>(_ : T.Type, xibName : String) ->T {
        return T(nibName: xibName, bundle: NSBundle(forClass: self))
    }
}

/// AppRouter utility methods for UIStoryboard
extension UIStoryboard {
    /// Utility constructor
    public convenience init(_ name: String, bundle: NSBundle? = NSBundle.mainBundle()) {
        self.init(name: name, bundle: bundle)
    }
    
    /// Instantiate initial controller or by controller class name. If instantiated controller is UINavigationController - tries to take it first controller
    ///
    /// - parameter type: required controller type
    /// - parameter initial: if true - instantiates initial viewController, if no - controller with String(self) identifier
    /// - returns: controller instance if everything is ok
    public func instantiateViewController<T:UIViewController>(type : T.Type, initial : Bool = false) -> T? {
        let controller = initial ? instantiateInitialViewController() : instantiateViewControllerWithIdentifier(String(T))
        if controller is T {
            return controller as? T
        }
        if let navigation = controller as? UINavigationController {
            return navigation.viewControllers.first as? T
        }
        return nil
    }
}