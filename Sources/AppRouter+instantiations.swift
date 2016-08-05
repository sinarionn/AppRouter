import Foundation
import UIKit

public protocol BundleForClassInstantiable { }

extension BundleForClassInstantiable where Self : UIViewController {
    public static func instantiate(storyboardName storyboardName : String? = nil, initial : Bool = false) -> Self? {
        return UIStoryboard(storyboardName ?? String(self), bundle: NSBundle(forClass: self)).instantiateViewController(self, initial: initial)
    }
}

extension UIViewController: BundleForClassInstantiable { }

extension UIViewController {
    public class func instantiateInsideNavigation(storyboardName storyboardName : String? = nil, initial : Bool = false) -> UINavigationController? {
        return UIStoryboard(storyboardName ?? String(self), bundle: NSBundle(forClass: self)).instantiateViewControllerInsideNavigation(self, initial: initial)
    }

    public class func instantiateFromXib(xibName : String? = nil) -> Self? {
        return _instantiateFromXib(self, xibName: xibName ?? String(self))
    }
    
    private class func _instantiateFromXib<T : UIViewController>(_ : T.Type, xibName : String) ->T {
        return T(nibName: xibName, bundle: NSBundle(forClass: self))
    }
}

extension UIStoryboard {
    public convenience init(_ name: String, bundle: NSBundle? = NSBundle.mainBundle()) {
        self.init(name: name, bundle: bundle)
    }
    
    /** Instantiate initial controller or by controller class name. If instantiated controller is UINavigationController - tries to take it first controller */
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
    
    public func instantiateViewControllerInsideNavigation<T:UIViewController>(klass : T.Type, initial : Bool = false) -> UINavigationController? {
        guard let navigation = initial ?
            instantiateInitialViewController() as? UINavigationController :
            instantiateViewControllerWithIdentifier(String(T)) as? UINavigationController
            where navigation.viewControllers.first is T else { return nil }
        return navigation
    }
}