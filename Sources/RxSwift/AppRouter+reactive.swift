//
//  AppRouter+reactive.swift
//  AppRouter
//
//  Created by Antihevich on 8/9/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

public protocol ARReactiveProxyProtocol {}
extension UIViewController : ARReactiveProxyProtocol {}
public extension ARReactiveProxyProtocol where Self: UIViewController {
    /// Observe viewDidLoad calls on current instance
    public func onViewDidLoad() -> Observable<Void> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didLoad.subscribeNext({ [weak self] vc in
                if vc === self {
                    observer.onNext()
                }
            })
        })
    }
    
    /// Observe viewWillAppear calls on current instance
    public func onViewWillAppear() -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willAppear.subscribeNext({ [weak self] (vc, animated) in
                if vc === self {
                    observer.onNext(animated)
                }
            })
        })
    }
    
    /// Observe viewDidAppear calls on current instance
    public func onViewDidAppear() -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didAppear.subscribeNext({ [weak self] (vc, animated) in
                if vc === self {
                    observer.onNext(animated)
                }
            })
        })
    }
    
    /// Observe viewWillDisappear calls on current instance
    public func onViewWillDisappear() -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willDisappear.subscribeNext({ [weak self] (vc, animated) in
                if vc === self {
                    observer.onNext(animated)
                }
            })
        })
    }
    
    /// Observe viewDidDisappear calls on current instance
    public func onViewDidDisappear() -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didDisappear.subscribeNext({ [weak self] (vc, animated) in
                if vc === self {
                    observer.onNext(animated)
                }
            })
        })
    }
}

public extension ARReactiveProxyProtocol where Self: UIViewController {
    /// observe viewDidLoad calls on all instances of current type
    public static func onViewDidLoad() -> Observable<Self> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didLoad.subscribeNext({ vc in
                if let required = vc as? Self {
                    observer.onNext(required)
                }
            })
        })
    }
    
    /// observe viewWillAppear calls on all instances of current type
    public static func onViewWillAppear() -> Observable<(controller: Self, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willAppear.subscribeNext({ (vc, animated) in
                if let required = vc as? Self {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewDidAppear calls on all instances of current type
    public static func onViewDidAppear() -> Observable<(controller: Self, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didAppear.subscribeNext({ (vc, animated) in
                if let required = vc as? Self {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewWillDisappear calls on all instances of current type
    public static func onViewWillDisappear() -> Observable<(controller: Self, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willDisappear.subscribeNext({ (vc, animated) in
                if let required = vc as? Self {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewDidDisappear calls on all instances of current type
    public static func onViewDidDisappear() -> Observable<(controller: Self, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didDisappear.subscribeNext({ (vc, animated) in
                if let required = vc as? Self {
                    observer.onNext((required, animated))
                }
            })
        })
    }
}

private class ARViewControllerLifeCircleManager {
    static let instance : ARViewControllerLifeCircleManager = {
        ARViewControllerLifeCircleManager.swizzleUIViewController()
        return ARViewControllerLifeCircleManager()
    }()
    private let didLoad = PublishSubject<UIViewController>()
    private let willAppear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    private let didAppear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    private let willDisappear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    private let didDisappear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    
    class func swizzleUIViewController() {
        struct Static { static var token: dispatch_once_t = 0 }
        dispatch_once(&Static.token) {
            swizzleUIViewControllerDidLoad()
            swizzleUIViewControllerWillAppear()
            swizzleUIViewControllerDidAppear()
            swizzleUIViewControllerWillDisappear()
            swizzleUIViewControllerDidDisappear()
        }
    }
    
    private class func swizzleUIViewControllerDidLoad() {
        let originalSelector = #selector(UIViewController.viewDidLoad)
        let swizzledSelector = #selector(UIViewController.ar_viewDidLoad)
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    private class func swizzleUIViewControllerWillAppear() {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(UIViewController.ar_viewWillAppear(_:))
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    private class func swizzleUIViewControllerDidAppear() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.ar_viewDidAppear(_:))
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    private class func swizzleUIViewControllerWillDisappear() {
        let originalSelector = #selector(UIViewController.viewWillDisappear(_:))
        let swizzledSelector = #selector(UIViewController.ar_viewWillDisappear(_:))
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    private class func swizzleUIViewControllerDidDisappear() {
        let originalSelector = #selector(UIViewController.viewDidDisappear(_:))
        let swizzledSelector = #selector(UIViewController.ar_viewDidDisappear(_:))
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    private class func swapMethods(original: Selector, swizzled: Selector) {
        let originalMethod = class_getInstanceMethod(UIViewController.self, original)
        let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzled)
        let didAddMethod = class_addMethod(UIViewController.self, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod { class_replaceMethod(UIViewController.self, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) }
        else { method_exchangeImplementations(originalMethod, swizzledMethod) }
    }
}

extension UIViewController {
    @objc private func ar_viewDidLoad() -> () {
        self.ar_viewDidLoad()
        ARViewControllerLifeCircleManager.instance.didLoad.onNext(self)
    }
    @objc private func ar_viewWillAppear(animated: Bool) -> () {
        self.ar_viewWillAppear(animated)
        ARViewControllerLifeCircleManager.instance.willAppear.onNext((self, animated))
    }
    @objc private func ar_viewDidAppear(animated: Bool) -> () {
        self.ar_viewDidAppear(animated)
        ARViewControllerLifeCircleManager.instance.didAppear.onNext((self, animated: animated))
    }
    @objc private func ar_viewWillDisappear(animated: Bool) -> () {
        self.ar_viewWillDisappear(animated)
        ARViewControllerLifeCircleManager.instance.willDisappear.onNext((self, animated: animated))
    }
    @objc private func ar_viewDidDisappear(animated: Bool) -> () {
        self.ar_viewDidDisappear(animated)
        ARViewControllerLifeCircleManager.instance.didDisappear.onNext((self, animated: animated))
    }
}

