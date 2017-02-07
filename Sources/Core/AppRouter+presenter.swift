import Foundation
import UIKit

/// Presenter aggregator class
open class ViewControllerPresentConfiguration<T: UIViewController> {
    /// Provides target on which presentation will be applied
    open var target : ARControllerProvider = ARPresentationTarget.top
    
    /// Provides controller which will be configured, embedded and presented
    open var source : ARControllerProvider = ARPresentationSource.storyboard(initial: true)
    
    /// Embeds source inside container (UINavigationController, UITabBarController, etc) which will be used for presentation
    open var embedder : (T) -> UIViewController? = { $0 }
    
    /// Configure source controller before presentation
    open var configurator: (T) -> () = { _ in }
    
    /// Declare AppRouter.topViewController to be a **target** provider
    open func onTop() -> ViewControllerPresentConfiguration {
        target = ARPresentationTarget.top
        return self
    }
    
    /// Declare AppRouter.rootViewController to be a **target** provider
    open func onRoot() -> ViewControllerPresentConfiguration {
        target = ARPresentationTarget.root
        return self
    }
    
    /// Declare custom **target** provider
    ///
    /// - parameter targetBlock: block should return target viewController which will be used for presentation
    open func onCustom(_ targetBlock : @escaping () -> UIViewController?) -> ViewControllerPresentConfiguration {
        target = ARPresentationTarget.anonymous(targetBlock)
        return self
    }
    
    /// Declare **source** provider to take controller from storyboard
    ///
    /// - parameter name: Storyboard name. Default value: controller type
    /// - parameter initial: Set this value if controller is initial in storyboard or it's rootController on initial UINavigationController
    open func fromStoryboard(_ name: String? = nil, initial : Bool = true) -> ViewControllerPresentConfiguration {
        if let name = name { source = ARPresentationSource.customStoryboard(name: name, inital: initial) }
        else { source = ARPresentationSource.storyboard(initial: initial) }
        return self
    }
    
    /// Declare **source** provider to take controller from xib
    ///
    /// - parameter name: Xib name. Default value: contollers type
    open func fromXib(_ name: String? = nil) -> ViewControllerPresentConfiguration {
        if let name = name { source = ARPresentationSource.customXib(name) }
        else { source = ARPresentationSource.xib }
        return self
    }
    
    /// Declare **configuration** block which used to configure controller before presentation
    ///
    /// - parameter configuration: block allows to apply additional configuration before presenting
    open func configure(_ configurator: @escaping (T) -> ()) -> ViewControllerPresentConfiguration {
        self.configurator = configurator
        return self
    }
    
    /// Declare **embedder** provider to embed controller in simple UINavigationController before presentation
    ///
    /// - parameter navigationController: set custom UINavigationController to be used
    open func embedInNavigation(_ navigationController: UINavigationController = UINavigationController()) -> ViewControllerPresentConfiguration {
        embedder = { source in
            navigationController.viewControllers.append(source)
            return navigationController
        }
        return self
    }
    
    /// Declare **embedder** provider to embed controller in UITabBarController before presentation
    ///
    /// - parameter tabBarController: UITabBarController - used as container of source controller
    open func embedInTabBar(_ tabBarController: UITabBarController) -> ViewControllerPresentConfiguration {
        embedder = { source in
            var originalCollection = tabBarController.viewControllers ?? []
            originalCollection.append(source)
            tabBarController.viewControllers = originalCollection
            return tabBarController
        }
        return self
    }
    
    /// Custom anonymous **embedder** provider
    ///
    /// - parameter embederBlock: block should return UIViewController which will be used as presentation target
    open func embedIn(_ embederBlock: @escaping (T) -> UIViewController?) -> ViewControllerPresentConfiguration {
        embedder = embederBlock
        return self
    }
    
    /// Push current configuration
    ///
    /// - parameter animated: Set this value to true to animate the transition.
    /// - parameter completion: The block to execute after the view controller is pushed.
    /// - returns: returns instance provided by `source` provider
    @discardableResult
    open func push(animated: Bool = true, completion: Func<Void, Void>? = nil) -> T? {
        guard let sourceController = source.provideController(T.self), let parent = provideEmbeddedController(sourceController) else { debug("error constructing source controller"); return nil }
        configurator(sourceController)
        guard let targetController = target.provideController(UIViewController.self) else { debug("error fetching target controller"); return nil }
        guard let targetNavigation = (targetController as? UINavigationController) ?? targetController.navigationController else { debug("error fetching navigation controller"); return nil }
        targetNavigation.pushViewController(parent, animated: animated, completion: completion)
        return sourceController
    }
    
    /// Present current configuration
    ///
    /// - parameter animated: Set this value to true to animate the transition.
    /// - parameter completion: The block to execute after the view controller is presented.
    /// - returns: returns instance provided by `source` provider
    @discardableResult
    open func present(animated: Bool = true, completion: Func<Void, Void>? = nil) -> T? {
        guard let sourceController = source.provideController(T.self), let parent = provideEmbeddedController(sourceController) else { debug("error constructing source controller"); return nil }
        configurator(sourceController)
        guard let targetController = target.provideController(UIViewController.self) else { debug("error fetching target controller"); return nil }
        targetController.present(parent, animated: animated, completion: completion)
        return sourceController
    }
    
    /// Provides source controller already configured for use.
    ///
    /// - returns: controller created from source.
    open func provideSourceController() -> T? {
        guard let sourceController = source.provideController(T.self) else { debug("error constructing source controller"); return nil }
        configurator(sourceController)
        return sourceController
    }
    
    /// Provides source controller embedded in `embedder` controller and configured for use.
    ///
    /// - returns: embedded controller.
    open func provideEmbeddedSourceController() -> UIViewController? {
        guard let sourceController = source.provideController(T.self) else { debug("error constructing source controller"); return nil }
        guard let embedded = provideEmbeddedController(sourceController) else { return nil }
        configurator(sourceController)
        return embedded
    }
    
    fileprivate func provideEmbeddedController(_ sourceController: T) -> UIViewController? {
        guard let parent = embedder(sourceController) else { debug("error embedding controller"); return nil }
        return parent
    }
    
    fileprivate func debug(_ str: String) {        
        AppRouter.print("#[Presenter<\(T.self)>] " + str)
    }
}

enum ARPresentationTarget : ARControllerProvider{
    case top
    case root
    case anonymous(() -> UIViewController?)
    func provideController<T : UIViewController>(_ type: T.Type) -> T? {
        switch self {
        case .top: return AppRouter.topViewController() as? T
        case .root: return AppRouter.rootViewController as? T
        case .anonymous(let provider): return provider() as? T
        }
    }
}

enum ARPresentationSource : ARControllerProvider {
    case storyboard(initial: Bool)
    case xib
    case customStoryboard(name: String, inital: Bool)
    case customXib(String)
    case preconstructed(UIViewController)
    func provideController<T : UIViewController>(_ type: T.Type) -> T? where T : BundleForClassInstantiable {
        switch self {
        case .storyboard(let initial): return T.instantiate(initial: initial)
        case .customStoryboard(let name, let initial): return T.instantiate(storyboardName: name, initial: initial)
        case .xib: return T.instantiateFromXib()
        case .customXib(let name): return T.instantiateFromXib(name)
        case .preconstructed(let vc): return vc as? T
        }
    }
}

/// Used for source and target controller providing
public protocol ARControllerProvider {
    /// It should return controller instance of specified type
    func provideController<T : UIViewController>(_ type: T.Type) -> T?
}


/// Workaround to use Self as generic constraint in method
public protocol ARControllerConfigurableProtocol : class {}
extension UIViewController : ARControllerConfigurableProtocol {}
extension ARControllerConfigurableProtocol where Self: UIViewController {
    /// Presentation configurator. Defaults: -onTop -fromStoryboard
    public static func presenter() -> ViewControllerPresentConfiguration<Self> {
        return ViewControllerPresentConfiguration()
    }
    
    /// Presentation configurator with current instance used as source. Default target - onTop
    public func presenter() -> ViewControllerPresentConfiguration<Self> {
        let configuration : ViewControllerPresentConfiguration<Self> = ViewControllerPresentConfiguration()
        configuration.source = ARPresentationSource.preconstructed(self)
        return configuration
    }
}
