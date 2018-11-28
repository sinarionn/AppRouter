
import UIKit
import RxSwift
import RxCocoa
import ReusableView
#if canImport(AppRouterExtensionAPI)
import AppRouterExtensionAPI
#endif
#if canImport(AppRouterLight)
import AppRouterLight
#endif

public protocol ViewFactoryType {
    func buildView<T>() throws -> T where T: UIViewController
    func buildView<T, ARG>(arg: ARG) throws -> T where T: UIViewController
}

public protocol ViewModelFactoryType {
    func buildViewModel<T>() throws -> T
    func buildViewModel<T, ARG>(arg: ARG) throws -> T
    func buildViewModel<T, ARG, ARG2>(arg: ARG, arg2: ARG2) throws -> T
    func buildViewModel<T, ARG, ARG2, ARG3>(arg: ARG, arg2: ARG2, arg3: ARG3) throws -> T
}

public protocol BasicRouteProtocol {
    associatedtype RouteTarget
    
    @discardableResult func push() throws -> RouteTarget
    @discardableResult func present() throws -> RouteTarget
    @discardableResult func setAsRoot() throws -> RouteTarget
    @discardableResult func show() throws -> RouteTarget
    func onWeak(_ controller: UIViewController?) -> Self
}

open class Route<T: UIViewController> : ARConfiguration<T> where T: ViewModelHolderType{
    open var viewModelProvider: () throws -> T.ViewModelType? = { nil }
    
    public let viewFactory: ViewFactoryType
    public let viewModelFactory: ViewModelFactoryType
    
    public init(viewFactory: ViewFactoryType, viewModelFactory: ViewModelFactoryType, router: AppRouterType) {
        self.viewFactory = viewFactory
        self.viewModelFactory = viewModelFactory
        super.init(router: router)
    }
    
    open override func performConfiguration(for source: T) throws {
        try self.performViewModelInsertion(for: source)
        try super.performConfiguration(for: source)
    }
    
    open func buildViewModel() -> Self {
        viewModelProvider = { [viewModelFactory] in try viewModelFactory.buildViewModel() }
        return self
    }
    
    open func buildViewModel<ARG>(_ arg: ARG) -> Self {
        viewModelProvider = { [viewModelFactory] in try viewModelFactory.buildViewModel(arg: arg) }
        return self
    }
    
    open func buildViewModel<ARG, ARG2>(_ arg: ARG, _ arg2: ARG2) -> Self {
        viewModelProvider = { [viewModelFactory] in try viewModelFactory.buildViewModel(arg: arg, arg2: arg2) }
        return self
    }
    
    open func buildViewModel<ARG, ARG2, ARG3>(_ arg: ARG, _ arg2: ARG2, _ arg3: ARG3) -> Self {
        viewModelProvider = { [viewModelFactory] in try viewModelFactory.buildViewModel(arg: arg, arg2: arg2, arg3: arg3) }
        return self
    }
    
    open func with(viewModel: T.ViewModelType) -> Self {
        viewModelProvider = { viewModel }
        return self
    }
    
    open func performViewModelInsertion(for source: T) throws {
        source.viewModel = try viewModelProvider()
    }
    
    open func fromFactory() -> Self {
        return from{ [viewFactory] in try viewFactory.buildView() as T }
    }
    
    open func fromFactory<U>(arg: U) -> Self {
        return from{ [viewFactory] in try viewFactory.buildView(arg: arg) as T }
    }
}

extension ObservableConvertibleType where Self.E: BasicRouteProtocol {
    public func push() -> Disposable {
        return self.asObservable().bind(onNext: {
            do {
                try $0.push()
            } catch {
                print("[Route] failed to push: \(error)")
            }
        })
    }
    public func push(on controller: UIViewController) -> Disposable {
        return self.asObservable().bind(onNext: { [weak controller] in
            do {
                try $0.onWeak(controller).push()
            } catch {
                print("[Route] failed to push: \(error)")
            }
        })
    }
    public func present() -> Disposable {
        return self.asObservable().bind(onNext: {
            do {
                try $0.present()
            } catch {
                print("[Route] failed to present: \(error)")
            }
        })
    }
    public func setAsRoot() -> Disposable {
        return self.asObservable().bind(onNext: {
            do {
                try $0.setAsRoot()
            } catch {
                print("[Route] failed to set as root: \(error)")
            }
        })
    }
    public func show() -> Disposable {
        return self.asObservable().bind(onNext: {
            do {
                try $0.show()
            } catch {
                print("[Route] failed to show: \(error)")
            }
        })
    }
}

extension ARConfiguration: BasicRouteProtocol {
    public func onWeak(_ controller: UIViewController?) -> Self {
        return on({ [weak controller] in
            return try controller ?? ARConfigurationErrors.failedToConstructTargetController.rethrow()
        })
    }
}


