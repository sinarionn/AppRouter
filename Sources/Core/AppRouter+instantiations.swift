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
    public static func instantiate(storyboardName : String? = nil, initial : Bool = false) -> Self? {
        return UIStoryboard(storyboardName ?? String(describing: self), bundle: Bundle(for: self)).instantiateViewController(self, initial: initial)
    }
}

/// AppRouter utility methods for UIViewController
extension UIViewController {
    /// Instantiates controller from xib.
    ///
    /// - parameter xibName: xib name to be used, if nil - String(self) will be used
    /// - returns: controller instance if everything is ok
    public class func instantiateFromXib(_ xibName : String? = nil) -> Self? {
        return _instantiateFromXib(self, xibName: xibName ?? String(describing: self))
    }
    
    fileprivate class func _instantiateFromXib<T : UIViewController>(_ : T.Type, xibName : String) ->T {
        return T(nibName: xibName, bundle: Bundle(for: self))
    }
}

/// AppRouter utility methods for UIStoryboard
extension UIStoryboard {
    /// Utility constructor
    public convenience init(_ name: String, bundle: Bundle? = Bundle.main) {
        self.init(name: name, bundle: bundle)
    }
    
    /// Instantiate initial controller or by controller class name. If instantiated controller is UINavigationController - tries to take it first controller
    ///
    /// - parameter type: required controller type
    /// - parameter initial: if true - instantiates initial viewController, if no - controller with String(self) identifier
    /// - returns: controller instance if everything is ok
    public func instantiateViewController<T:UIViewController>(_ type : T.Type, initial : Bool = false) -> T? {
        let controller = initial ? instantiateInitialViewController() : self.instantiateViewController(withIdentifier: String(describing: T.self))
        if controller is T {
            return controller as? T
        }
        if let navigation = controller as? UINavigationController {
            let first = navigation.viewControllers.first as? T
            first?.removeFromParentViewController()
            return first
        }
        return nil
    }
}
