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

protocol ARReactiveProxyProtocol {}
extension UIViewController : ARReactiveProxyProtocol {}
extension ARReactiveProxyProtocol where Self: UIViewController {
    /// Observe viewDidLoad calls on current instance
    func onViewDidLoad() -> Observable<Void> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didLoad.subscribe(onNext: { [weak self] vc in
                if vc === self {
                    observer.onNext()
                }
            })
        })
    }
    
    /// Observe viewWillAppear calls on current instance
    func onViewWillAppear() -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willAppear.subscribe(onNext: { [weak self] (vc, animated) in
                if vc === self {
                    observer.onNext(animated)
                }
            })
        })
    }
    
    /// Observe viewDidAppear calls on current instance
    func onViewDidAppear() -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didAppear.subscribe(onNext: { [weak self] (vc, animated) in
                if vc === self {
                    observer.onNext(animated)
                }
            })
        })
    }
    
    /// Observe viewWillDisappear calls on current instance
    func onViewWillDisappear() -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willDisappear.subscribe(onNext: { [weak self] (vc, animated) in
                if vc === self {
                    observer.onNext(animated)
                }
            })
        })
    }
    
    /// Observe viewDidDisappear calls on current instance
    func onViewDidDisappear() -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didDisappear.subscribe(onNext: { [weak self] (vc, animated) in
                if vc === self {
                    observer.onNext(animated)
                }
            })
        })
    }
}

extension ARReactiveProxyProtocol where Self: UIViewController {
    /// observe viewDidLoad calls on all instances of current type
    static func onViewDidLoad() -> Observable<Self> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didLoad.subscribe(onNext: { vc in
                if let required = vc as? Self {
                    observer.onNext(required)
                }
            })
        })
    }
    
    /// observe viewWillAppear calls on all instances of current type
    static func onViewWillAppear() -> Observable<(controller: Self, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willAppear.subscribe(onNext: { (vc, animated) in
                if let required = vc as? Self {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewDidAppear calls on all instances of current type
    static func onViewDidAppear() -> Observable<(controller: Self, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didAppear.subscribe(onNext: { (vc, animated) in
                if let required = vc as? Self {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewWillDisappear calls on all instances of current type
    static func onViewWillDisappear() -> Observable<(controller: Self, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willDisappear.subscribe(onNext: { (vc, animated) in
                if let required = vc as? Self {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewDidDisappear calls on all instances of current type
    static func onViewDidDisappear() -> Observable<(controller: Self, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didDisappear.subscribe(onNext: { (vc, animated) in
                if let required = vc as? Self {
                    observer.onNext((required, animated))
                }
            })
        })
    }
}

private class ARViewControllerLifeCircleManager {
    private static var __once: () = {
            swizzleUIViewControllerDidLoad()
            swizzleUIViewControllerWillAppear()
            swizzleUIViewControllerDidAppear()
            swizzleUIViewControllerWillDisappear()
            swizzleUIViewControllerDidDisappear()
        }()
    static let instance : ARViewControllerLifeCircleManager = {
        ARViewControllerLifeCircleManager.swizzleUIViewController()
        return ARViewControllerLifeCircleManager()
    }()
    fileprivate let didLoad = PublishSubject<UIViewController>()
    fileprivate let willAppear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let didAppear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let willDisappear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let didDisappear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    
    class func swizzleUIViewController() {
        struct Static { static var token: Int = 0 }
        _ = ARViewControllerLifeCircleManager.__once
    }
    
    fileprivate class func swizzleUIViewControllerDidLoad() {
        let originalSelector = #selector(UIViewController.viewDidLoad)
        let swizzledSelector = #selector(UIViewController.ar_viewDidLoad)
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    fileprivate class func swizzleUIViewControllerWillAppear() {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(UIViewController.ar_viewWillAppear(_:))
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    fileprivate class func swizzleUIViewControllerDidAppear() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.ar_viewDidAppear(_:))
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    fileprivate class func swizzleUIViewControllerWillDisappear() {
        let originalSelector = #selector(UIViewController.viewWillDisappear(_:))
        let swizzledSelector = #selector(UIViewController.ar_viewWillDisappear(_:))
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    fileprivate class func swizzleUIViewControllerDidDisappear() {
        let originalSelector = #selector(UIViewController.viewDidDisappear(_:))
        let swizzledSelector = #selector(UIViewController.ar_viewDidDisappear(_:))
        swapMethods(originalSelector, swizzled: swizzledSelector)
    }
    
    fileprivate class func swapMethods(_ original: Selector, swizzled: Selector) {
        let originalMethod = class_getInstanceMethod(UIViewController.self, original)
        let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzled)
        let didAddMethod = class_addMethod(UIViewController.self, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod { class_replaceMethod(UIViewController.self, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) }
        else { method_exchangeImplementations(originalMethod, swizzledMethod) }
    }
}

extension UIViewController {
    @objc fileprivate func ar_viewDidLoad() -> () {
        self.ar_viewDidLoad()
        ARViewControllerLifeCircleManager.instance.didLoad.onNext(self)
    }
    @objc fileprivate func ar_viewWillAppear(_ animated: Bool) -> () {
        self.ar_viewWillAppear(animated)
        ARViewControllerLifeCircleManager.instance.willAppear.onNext((self, animated))
    }
    @objc fileprivate func ar_viewDidAppear(_ animated: Bool) -> () {
        self.ar_viewDidAppear(animated)
        ARViewControllerLifeCircleManager.instance.didAppear.onNext((self, animated: animated))
    }
    @objc fileprivate func ar_viewWillDisappear(_ animated: Bool) -> () {
        self.ar_viewWillDisappear(animated)
        ARViewControllerLifeCircleManager.instance.willDisappear.onNext((self, animated: animated))
    }
    @objc fileprivate func ar_viewDidDisappear(_ animated: Bool) -> () {
        self.ar_viewDidDisappear(animated)
        ARViewControllerLifeCircleManager.instance.didDisappear.onNext((self, animated: animated))
    }
}

