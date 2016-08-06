import Foundation
import UIKit

/// Presenter aggregator class
public class ViewControllerPresentConfiguration<T: UIViewController> {
    /// Provides target on which presentation will be applied
    public var target : ARControllerProvider = ARPresentationTarget.Top
    
    /// Provides controller which will be configured, embedded and presented
    public var source : ARControllerProvider = ARPresentationSource.Storyboard(false)
    
    /// Embeds source inside container (UINavigationController, UITabBarController, etc) which will be used for presentation
    public var embedder : T -> UIViewController? = { $0 }
    
    /// Configure source controller before presentation
    public var configurator: T -> () = { _ in }
    
    /// Declare AppRouter.topViewController to be a **target** provider
    public func onTop() -> ViewControllerPresentConfiguration {
        target = ARPresentationTarget.Top
        return self
    }
    
    /// Declare AppRouter.rootViewController to be a **target** provider
    public func onRoot() -> ViewControllerPresentConfiguration {
        target = ARPresentationTarget.Root
        return self
    }
    
    /// Declare custom **target** provider
    ///
    /// - parameter targetBlock: block should return target viewController which will be used for presentation
    public func onCustom(targetBlock : () -> UIViewController?) -> ViewControllerPresentConfiguration {
        target = ARPresentationTarget.Anonymous(targetBlock)
        return self
    }
    
    /// Declare **source** provider to take controller from storyboard
    ///
    /// - parameter name: Storyboard name. Default value: controller type
    /// - parameter initial: Set this value if controller is initial in storyboard or it's rootController on initial UINavigationController
    public func fromStoryboard(name: String? = nil, initial : Bool = false) -> ViewControllerPresentConfiguration {
        if let name = name { source = ARPresentationSource.CustomStoryboard(name, initial) }
        else { source = ARPresentationSource.Storyboard(initial) }
        return self
    }
    
    /// Declare **source** provider to take controller from xib
    ///
    /// - parameter name: Xib name. Default value: contollers type
    public func fromXib(name: String? = nil) -> ViewControllerPresentConfiguration {
        if let name = name { source = ARPresentationSource.CustomXib(name) }
        else { source = ARPresentationSource.Xib }
        return self
    }
    
    /// Declare **configuration** block which used to configure controller before presentation
    ///
    /// - parameter configuration: block allows to apply additional configuration before presenting
    public func configure(configurator: T -> ()) -> ViewControllerPresentConfiguration {
        self.configurator = configurator
        return self
    }
    
    /// Declare **embedder** provider to embed controller in simple UINavigationController before presentation
    ///
    /// - parameter navigationController: set custom UINavigationController to be used
    public func embedInNavigation(navigationController: UINavigationController = UINavigationController()) -> ViewControllerPresentConfiguration {
        embedder = { source in
            navigationController.viewControllers.append(source)
            return navigationController
        }
        return self
    }
    
    /// Declare **embedder** provider to embed controller in UITabBarController before presentation
    ///
    /// - parameter tabBarController: UITabBarController - used as container of source controller
    public func embedInTabBar(tabBarController: UITabBarController) -> ViewControllerPresentConfiguration {
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
    public func embedIn(embederBlock: T -> UIViewController?) -> ViewControllerPresentConfiguration {
        embedder = embederBlock
        return self
    }
    
    /// Push current configuration
    ///
    /// - parameter animated: Set this value to true to animate the transition.
    /// - parameter completion: The block to execute after the view controller is pushed.
    /// - returns: returns instance provided by `source` provider
    public func push(animated animated: Bool = true, completion: Action? = nil) -> T? {
        guard let sourceController = provideSourceController(),
            let parent = provideEmbeddedController(sourceController) else { return nil }
        guard let targetController = target.provideController(UIViewController) else { debug("error fetching target controller"); return nil }
        guard let targetNavigation = (targetController as? UINavigationController) ?? targetController.navigationController else { debug("error fetching navigation controller"); return nil }
        targetNavigation.pushViewController(parent, animated: animated, completion: completion)
        return sourceController
    }
    
    /// Present current configuration
    ///
    /// - parameter animated: Set this value to true to animate the transition.
    /// - parameter completion: The block to execute after the view controller is presented.
    /// - returns: returns instance provided by `source` provider
    public func present(animated animated: Bool = true, completion: Action? = nil) -> T? {
        guard let sourceController = provideSourceController(), let parent = provideEmbeddedController(sourceController) else { return nil }
        guard let targetController = target.provideController(UIViewController) else { debug("error fetching target controller"); return nil }
        targetController.presentViewController(parent, animated: animated, completion: completion)
        return sourceController
    }
    
    /// Provides source controller already configured for use.
    ///
    /// - returns: controller created from source.
    public func provideSourceController() -> T? {
        guard let sourceController = source.provideController(T) else { debug("error constructing source controller"); return nil }
        configurator(sourceController)
        return sourceController
    }
    
    /// Provides source controller embedded in `embedder` controller.
    ///
    /// - returns: embedded controller.
    public func provideEmbeddedSourceController() -> UIViewController? {
        guard let sourceController = provideSourceController() else { return nil }
        guard let embedded = provideEmbeddedController(sourceController) else { return nil }
        return embedded
    }
    
    private func provideEmbeddedController(sourceController: T) -> UIViewController? {
        guard let parent = embedder(sourceController) else { debug("error embedding controller"); return nil }
        return parent
    }
    
    private func debug(str: String) {        
        AppRouter.print("#[Presenter<\(T.self)>] " + str)
    }
}

enum ARPresentationTarget : ARControllerProvider{
    case Top
    case Root
    case Anonymous(() -> UIViewController?)
    func provideController<T : UIViewController>(type: T.Type) -> T? {
        switch self {
        case Top: return AppRouter.topViewController() as? T
        case Root: return AppRouter.rootViewController as? T
        case Anonymous(let provider): return provider() as? T
        }
    }
}

enum ARPresentationSource : ARControllerProvider {
    case Storyboard(Bool)
    case Xib
    case CustomStoryboard(String, Bool)
    case CustomXib(String)
    case Preconstructed(UIViewController)
    func provideController<T : UIViewController where T : BundleForClassInstantiable>(type: T.Type) -> T? {
        switch self {
        case .Storyboard(let initial): return T.instantiate(initial: initial)
        case .CustomStoryboard(let name, let initial): return T.instantiate(storyboardName: name, initial: initial)
        case .Xib: return T.instantiateFromXib()
        case .CustomXib(let name): return T.instantiateFromXib(name)
        case .Preconstructed(let vc): return vc as? T
        }
    }
}

/// Used for source and target controller providing
public protocol ARControllerProvider {
    /// It should return controller instance of specified type
    func provideController<T : UIViewController>(type: T.Type) -> T?
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
        configuration.source = ARPresentationSource.Preconstructed(self)
        return configuration
    }
}