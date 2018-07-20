//
//  AppRouter+reactive.swift
//  AppRouter
//
//  Created by Antihevich on 8/9/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

public extension Reactive where Base: UIViewController {
    /// Observe viewDidLoad calls on current instance
    public func onViewDidLoad() -> Signal<Void> {
        return ARViewControllerLifeCycleManager.instance.didLoad.asSignal(onErrorSignalWith: .empty()).filter{ [weak base] in $0 === base }.map{ _ in () }
    }
    
    /// Observe viewWillAppear calls on current instance
    public func onViewWillAppear() -> Signal<Bool> {
        return filterInstance(ARViewControllerLifeCycleManager.instance.willAppear)
    }
    
    /// Observe viewDidAppear calls on current instance
    public func onViewDidAppear() -> Signal<Bool> {
        return filterInstance(ARViewControllerLifeCycleManager.instance.didAppear)
    }
    
    /// Observe viewWillDisappear calls on current instance
    public func onViewWillDisappear() -> Signal<Bool> {
        return filterInstance(ARViewControllerLifeCycleManager.instance.willDisappear)
    }
    
    /// Observe viewDidDisappear calls on current instance
    public func onViewDidDisappear() -> Signal<Bool> {
        return filterInstance(ARViewControllerLifeCycleManager.instance.didDisappear)
    }
    
    private func filterInstance(_ publisher: PublishSubject<(controller: UIViewController,animated: Bool)>) -> Signal<Bool> {
        return publisher.asSignal(onErrorSignalWith: .empty()).filter{ [weak base] in $0.controller === base }.map{ $0.animated }
    }
}

public extension Reactive where Base: UIViewController {
    /// observe viewDidLoad calls on all instances of current type
    public static func onViewDidLoad() -> Signal<Base> {
        return ARViewControllerLifeCycleManager.instance.didLoad.asSignal(onErrorSignalWith: .empty()).flatMap{
            if let required = $0 as? Base {
                return .just(required)
            } else {
                return .empty()
            }
        }
    }
    
    /// observe viewWillAppear calls on all instances of current type
    public static func onViewWillAppear() -> Signal<(controller: Base, animated: Bool)> {
        return filterBase(ARViewControllerLifeCycleManager.instance.willAppear)
    }
    
    /// observe viewDidAppear calls on all instances of current type
    public static func onViewDidAppear() -> Signal<(controller: Base, animated: Bool)> {
        return filterBase(ARViewControllerLifeCycleManager.instance.didAppear)
    }
    
    /// observe viewWillDisappear calls on all instances of current type
    public static func onViewWillDisappear() -> Signal<(controller: Base, animated: Bool)> {
        return filterBase(ARViewControllerLifeCycleManager.instance.willDisappear)
    }
    
    /// observe viewDidDisappear calls on all instances of current type
    public static func onViewDidDisappear() -> Signal<(controller: Base, animated: Bool)> {
        return filterBase(ARViewControllerLifeCycleManager.instance.didDisappear)
    }
    
    private static func filterBase(_ publisher: PublishSubject<(controller: UIViewController,animated: Bool)>) -> Signal<(controller: Base, animated: Bool)> {
        return publisher.asSignal(onErrorSignalWith: .empty()).flatMap{
            if let required = $0 as? Base {
                return .just((required, $1))
            } else {
                return .empty()
            }
        }
    }
}

private class ARViewControllerLifeCycleManager {
    private static var __once: () = {
        swapMethods(#selector(UIViewController.viewDidLoad), swizzled: #selector(UIViewController.ar_viewDidLoad))
        swapMethods(#selector(UIViewController.viewWillAppear(_:)), swizzled: #selector(UIViewController.ar_viewWillAppear(_:)))
        swapMethods(#selector(UIViewController.viewDidAppear(_:)), swizzled: #selector(UIViewController.ar_viewDidAppear(_:)))
        swapMethods(#selector(UIViewController.viewWillDisappear(_:)), swizzled: #selector(UIViewController.ar_viewWillDisappear(_:)))
        swapMethods(#selector(UIViewController.viewDidDisappear(_:)), swizzled: #selector(UIViewController.ar_viewDidDisappear(_:)))
    }()
    static let instance : ARViewControllerLifeCycleManager = {
        _ = __once
        return ARViewControllerLifeCycleManager()
    }()
    fileprivate let didLoad = PublishSubject<UIViewController>()
    fileprivate let willAppear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let didAppear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let willDisappear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let didDisappear = PublishSubject<(controller: UIViewController,animated: Bool)>()

    fileprivate class func swapMethods(_ original: Selector, swizzled: Selector) {
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, original),
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzled) else { return }
        let didAddMethod = class_addMethod(UIViewController.self, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod { class_replaceMethod(UIViewController.self, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) }
        else { method_exchangeImplementations(originalMethod, swizzledMethod) }
    }
}

extension UIViewController {
    @objc fileprivate func ar_viewDidLoad() -> () {
        self.ar_viewDidLoad()
        ARViewControllerLifeCycleManager.instance.didLoad.onNext(self)
    }
    @objc fileprivate func ar_viewWillAppear(_ animated: Bool) -> () {
        self.ar_viewWillAppear(animated)
        ARViewControllerLifeCycleManager.instance.willAppear.onNext((self, animated))
    }
    @objc fileprivate func ar_viewDidAppear(_ animated: Bool) -> () {
        self.ar_viewDidAppear(animated)
        ARViewControllerLifeCycleManager.instance.didAppear.onNext((self, animated: animated))
    }
    @objc fileprivate func ar_viewWillDisappear(_ animated: Bool) -> () {
        self.ar_viewWillDisappear(animated)
        ARViewControllerLifeCycleManager.instance.willDisappear.onNext((self, animated: animated))
    }
    @objc fileprivate func ar_viewDidDisappear(_ animated: Bool) -> () {
        self.ar_viewDidDisappear(animated)
        ARViewControllerLifeCycleManager.instance.didDisappear.onNext((self, animated: animated))
    }
}
    
#endif
