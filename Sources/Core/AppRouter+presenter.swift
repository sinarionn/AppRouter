import Foundation
import UIKit

extension AppRouter {
    open class Presenter {
        /// Factory for Configurations construction. Can be replaced with your own.
        public static var configurationFactory: ARPresentConfigurationFactory = AppRouter.Presenter.DefaultBuilder()
    }
}

/// Used for PresentConfiguration construction
public protocol ARPresentConfigurationFactory {
    func buildPresenter<T>() -> AppRouter.Presenter.Configuration<T>
}

public protocol AppRouterType: class {
    var window: UIWindow { get }
    var topViewController: UIViewController? { get }
    var rootViewController: UIViewController? { get set }
}

extension AppRouter: AppRouterType {}

extension AppRouter.Presenter {
    /// Presenter aggregator class
    open class Configuration<T: UIViewController> {
        /// Base router to work with
        var router: AppRouterType
        
        /// Provides target on which presentation will be applied
        var targetProvider : () throws -> UIViewController
        
        /// Provides controller which will be configured, embedded and presented
        var sourceProvider : () throws -> T = PresentationSource.storyboard(initial: true).provideController
        
        /// Embeds source inside container (UINavigationController, UITabBarController, etc) which will be used for presentation
        var embedder : (T) throws -> UIViewController = { $0 }
        
        /// handler, used as show action
        var showHandler: (AppRouter.Presenter.Configuration<T>) throws -> T = { _ in throw Errors.notImplemented }
        
        /// Configure source controller before presentation
        open var configurations: [(label: String, block: (T) throws -> ())] = []
        
        /// Declare router.topViewController to be a **target** provider
        open func onTop() -> Self {
            targetProvider = PresentationTarget.top(router).provideController
            return self
        }
        
        /// Declare router.rootViewController to be a **target** provider
        open func onRoot() -> Self {
            targetProvider = PresentationTarget.root(router).provideController
            return self
        }
        
        /// Declare custom **target** provider
        ///
        /// - parameter provider: block should return target viewController which will be used for presentation
        open func on(_ provider: @escaping () throws -> UIViewController) -> Self {
            targetProvider = provider
            return self
        }
        
        /// Declare **source** provider to take controller from storyboard
        ///
        /// - parameter name: Storyboard name. Default value: controller type
        /// - parameter initial: Set this value if controller is initial in storyboard or it's rootController on initial UINavigationController
        open func fromStoryboard(_ name: String? = nil, initial : Bool = true) -> Self {
            if let name = name { sourceProvider = PresentationSource.customStoryboard(name: name, inital: initial).provideController }
            else { sourceProvider = PresentationSource.storyboard(initial: initial).provideController }
            return self
        }
        
        /// Declare **source** provider to take controller from xib
        ///
        /// - parameter name: Xib name. Default value: contollers type
        open func fromXib(_ name: String? = nil) -> Self {
            if let name = name { sourceProvider = PresentationSource.customXib(name).provideController }
            else { sourceProvider = PresentationSource.xib.provideController }
            return self
        }
        
        /// Declare **source** factory to take controller from
        ///
        /// - parameter provider: closure that providers source controller
        open func from(provider: @escaping () throws -> T) -> Self {
            sourceProvider = provider
            return self
        }
        
        /// Declare **configuration** block which used to configure controller before presentation
        /// Configurations will be called in the order they was added.
        ///
        /// - parameter label: block label, only latest block will be stored for each label
        /// - parameter configuration: block allows to apply additional configuration before presenting
        open func configure(_ label: CustomStringConvertible, _ configuration: @escaping (T) throws -> ()) -> Self {
            configurations = configurations.filter{ $0.label != label.description } + [(label.description, configuration)]
            return self
        }
        
        /// Declare **configuration** block which used to configure controller before presentation
        ///
        /// - parameter configuration: block with default empty label, allows to apply additional configuration before presenting
        open func configure(_ configuration: @escaping (T) throws -> ()) -> Self {
            return configure("", configuration)
        }
        
        /// Declare **embedder** provider to embed controller in simple UINavigationController before presentation
        ///
        /// - parameter navigationController: set custom UINavigationController to be used
        open func embedInNavigation(_ navigationController: @autoclosure @escaping () -> UINavigationController = UINavigationController()) -> Self {
            embedder = { source in
                let nav = navigationController()
                nav.viewControllers.append(source)
                return nav
            }
            return self
        }
        
        /// Declare **embedder** provider to embed controller in UITabBarController before presentation
        ///
        /// - parameter tabBarController: UITabBarController - used as container of source controller
        open func embedInTabBar(_ tabBarController: UITabBarController) -> Self {
            embedder = { source in
                tabBarController.viewControllers = tabBarController.viewControllers ?? [] + [source]
                return tabBarController
            }
            return self
        }
        
        /// Custom anonymous **embedder** provider
        ///
        /// - parameter embederBlock: block should return UIViewController which will be used as presentation target
        open func embedIn(_ embederBlock: @escaping (T) throws -> UIViewController) -> Self {
            embedder = embederBlock
            return self
        }
        
        /// Push current configuration
        ///
        /// - parameter animated: Set this value to true to animate the transition.
        /// - parameter completion: The block to execute after the view controller is pushed.
        /// - returns: returns instance provided by `source` provider
        @discardableResult
        open func push(animated: Bool, completion: (()->())? = nil) throws -> T {
            let embedded = try provideEmbeddedSourceController()
            guard !(embedded.parent is UINavigationController) else { throw Errors.tryingToPushNavigationController }
            let targetController = try performTargetConstruction() as UIViewController
            let targetNavigation = try targetController as? UINavigationController ??
                                       targetController.navigationController ??
                                       Errors.failedToFindNavigationControllerToPushOn.rethrow()
            targetNavigation.pushViewController(embedded.parent, animated: animated, completion: completion)
            return embedded.child
        }
        
        /// Push current configuration
        ///
        /// - returns: returns instance provided by `source` provider
        @discardableResult
        open func push() throws -> T {
            return try push(animated: true)
        }
        
        /// Present current configuration
        ///
        /// - parameter animated: Set this value to true to animate the transition.
        /// - parameter completion: The block to execute after the view controller is presented.
        /// - returns: returns instance provided by `source` provider
        @discardableResult
        open func present(animated: Bool, completion: (()->())? = nil) throws -> T {
            let embedded = try provideEmbeddedSourceController()
            let targetController = try performTargetConstruction() as UIViewController
            targetController.present(embedded.parent, animated: animated, completion: completion)
            return embedded.child
        }
        
        /// Present current configuration
        ///
        /// - returns: returns instance provided by `source` provider
        @discardableResult
        open func present() throws -> T {
            return try present(animated: true)
        }

        /// Set embedded controller as rootViewController
        ///
        /// - parameter animation: Animation configuration
        /// - parameter completion: The block to execute after the view controller is setted.
        /// - returns: returns instance provided by `source` provider
        @discardableResult
        open func setAsRoot(animation: AppRouter.Animators.AnimationType, completion: ((Bool)->())? = nil) throws -> T {
            let embedded = try provideEmbeddedSourceController()
            router.animator.setRoot(controller: embedded.parent, animation: animation, callback: completion)
            return embedded.child
        }
        
        /// Set embedded controller as rootViewController with window crossDissolve animation
        ///
        /// - returns: returns instance provided by `source` provider
        @discardableResult
        open func setAsRoot() throws -> T {
            return try setAsRoot(animation: .window(options: .transitionCrossDissolve, duration: 0.3))
        }
        
        /// Declare custom show action
        ///
        /// - parameter handler: block should return target viewController which will be used for presentation
        open func handleShow(by handler: @escaping (AppRouter.Presenter.Configuration<T>) throws -> T) -> Self {
            self.showHandler = handler
            return self
        }
        
        /// Performs custom show action, provided throug handleShow method.
        ///
        /// - returns: returns instance provided by `source` provider
        @discardableResult
        open func show() throws -> T {
            return try showHandler(self)
        }
        
        /// Provides source controller already configured for use.
        ///
        /// - returns: controller created from source.
        open func provideSourceController() throws -> T {
            let sourceController = try performSourceConstruction()
            try performConfiguration(for: sourceController)
            return sourceController
        }
        
        /// Provides source controller embedded in `embedder` controller and configured for use.
        ///
        /// - returns: embedded controller.
        open func provideEmbeddedSourceController() throws -> (child: T, parent: UIViewController) {
            let sourceController = try performSourceConstruction()
            let embedded = try performEmbed(for: sourceController)
            try performConfiguration(for: sourceController)
            return (child: sourceController, parent: embedded)
        }
        
        /// Override point to perform additional logic while constructing source controller
        ///
        /// - returns: source controller.
        open func performSourceConstruction() throws -> T {
            return try sourceProvider()
        }
        
        /// Override point to perform additional logic while constructing target controller
        ///
        /// - returns: target controller.
        open func performTargetConstruction<U: UIViewController>() throws -> U {
            return try targetProvider() as? U ?? Errors.failedToConstructTargetController.rethrow()
        }
        
        /// Override point to perform additional logic while embedding source controller
        ///
        /// - returns: parent controller
        open func performEmbed(for source: T) throws -> UIViewController {
            return try embedder(source)
        }
        
        /// Override point to perform additional logic while configuring source controller
        ///
        /// - parameter for: source controller to perform configuration on
        open func performConfiguration(for source: T) throws -> Void {
            if #available(iOS 9.0, *) {
                source.loadViewIfNeeded()
            } else {
                _ = source.view
            }
            return try configurations.forEach{ try $0.block(source) }
        }
        
        public init(router: AppRouterType = AppRouter.shared) {
            self.router = router
            self.targetProvider = PresentationTarget.top(router).provideController
        }
    }
    
    public enum Errors: LocalizedError {
        case failedToConstructSourceController
        case failedToConstructTargetController
        case failedToEmbedSourceController
        case failedToFindNavigationControllerToPushOn
        case tryingToPushNavigationController
        case notImplemented
        
        public var errorDescription: String? {
            switch self {
            case .failedToConstructSourceController:
                return "[AppRouter][Presenter] failed to construct source controller."
            case .failedToConstructTargetController:
                return "[AppRouter][Presenter] failed to construct target controller."
            case .failedToEmbedSourceController:
                return "[AppRouter][Presenter] failed to embed source controller."
            case .failedToFindNavigationControllerToPushOn:
                return "[AppRouter][Presenter] failed to find navigation controller (using target provider) to push on."
            case .tryingToPushNavigationController:
                return "[AppRouter][Presenter] trying to push navigation controller (provided by source provider)."
            case .notImplemented:
                return "[AppRouter][Presenter] method not implemented."
            }
        }
    }
    
    public enum PresentationTarget {
        case top(AppRouterType)
        case root(AppRouterType)
        case anonymous(() throws -> UIViewController)
        public func provideController<T: UIViewController>() throws -> T {
            switch self {
            case .top(let router):
                return try router.topViewController as? T ?? Errors.failedToConstructTargetController.rethrow()
            case .root(let router):
                return try router.rootViewController as? T ?? Errors.failedToConstructTargetController.rethrow()
            case .anonymous(let provider):
                return try provider() as? T ?? Errors.failedToConstructTargetController.rethrow()
            }
        }
    }
    
    public enum PresentationSource {
        case storyboard(initial: Bool)
        case xib
        case customStoryboard(name: String, inital: Bool)
        case customXib(String)
        case preconstructed(UIViewController)
        case anonymous(() throws -> UIViewController)
        public func provideController<T: UIViewController>() throws -> T {
            switch self {
            case .storyboard(let initial):
                return try T.instantiate(initial: initial) ?? Errors.failedToConstructSourceController.rethrow()
            case .customStoryboard(let name, let initial):
                return try T.instantiate(storyboardName: name, initial: initial) ?? Errors.failedToConstructSourceController.rethrow()
            case .xib:
                return try T.instantiateFromXib() ?? Errors.failedToConstructSourceController.rethrow()
            case .customXib(let name):
                return try T.instantiateFromXib(name) ?? Errors.failedToConstructSourceController.rethrow()
            case .preconstructed(let vc):
                return try vc as? T ?? Errors.failedToConstructSourceController.rethrow()
            case .anonymous(let provider):
                return try provider() as? T ?? Errors.failedToConstructSourceController.rethrow()
            }
        }
    }
    
    internal struct DefaultBuilder: ARPresentConfigurationFactory {
        func buildPresenter<T>() -> AppRouter.Presenter.Configuration<T> where T : UIViewController {
            return .init()
        }
    }
}

extension Error {
    public func rethrow<T>() throws -> T {
        throw self
    }
}

/// Workaround to use Self as generic constraint in method
public protocol ARControllerConfigurableProtocol : class {}
extension UIViewController : ARControllerConfigurableProtocol {}
extension ARControllerConfigurableProtocol where Self: UIViewController {
    /// Presentation configurator. Defaults: -onTop -fromStoryboard
    public static func presenter() -> AppRouter.Presenter.Configuration<Self> {
        return AppRouter.Presenter.configurationFactory.buildPresenter()
    }
    
    /// Presentation configurator with current instance used as source. Default target - onTop. Warrning - current controller instance will be captured.
    public func presenter() -> AppRouter.Presenter.Configuration<Self> {
        return AppRouter.Presenter.configurationFactory.buildPresenter().from{ self }
    }
}
