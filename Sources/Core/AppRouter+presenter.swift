import Foundation
import UIKit
#if canImport(AppRouterExtensionAPI)
import AppRouterExtensionAPI
#endif
#if canImport(AppRouterLight)
import AppRouterLight
#endif

extension AppRouter {
    open class Presenter {
        /// Factory for Configurations construction. Can be replaced with your own.
        public static var configurationFactory: ARPresentConfigurationFactory = AppRouter.Presenter.DefaultBuilder()
    }
}

/// Used for PresentConfiguration construction
public protocol ARPresentConfigurationFactory {
    func buildPresenter<T>() -> ARConfiguration<T>
}

extension AppRouter: AppRouterType {}

extension AppRouter.Presenter {
    internal struct DefaultBuilder: ARPresentConfigurationFactory {
        func buildPresenter<T>() -> ARConfiguration<T> where T : UIViewController {
            return .init(router: AppRouter.shared)
        }
    }
}

/// Workaround to use Self as generic constraint in method
public protocol ARControllerConfigurableProtocol : AnyObject {}
extension UIViewController : ARControllerConfigurableProtocol {}
extension ARControllerConfigurableProtocol where Self: UIViewController {
    /// Presentation configurator. Defaults: -onTop -fromStoryboard
    public static func presenter() -> ARConfiguration<Self> {
        return AppRouter.Presenter.configurationFactory.buildPresenter()
    }
    
    /// Presentation configurator with current instance used as source. Default target - onTop. Warrning - current controller instance will be captured.
    public func presenter() -> ARConfiguration<Self> {
        return AppRouter.Presenter.configurationFactory.buildPresenter().from{ self }
    }
}
