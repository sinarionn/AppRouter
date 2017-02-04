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

public extension Reactive where Base: UIViewController {
    /// Observe viewDidLoad calls on current instance
    public func onViewDidLoad() -> Observable<Void> {
        return ARViewControllerLifeCircleManager.instance.didLoad.filter{ [weak base] in $0 === base }.map{ _ in () }
    }
    
    /// Observe viewWillAppear calls on current instance
    public func onViewWillAppear() -> Observable<Bool> {
        return ARViewControllerLifeCircleManager.instance.willAppear.filter{ [weak base] in $0.controller === base }.map{ $0.animated }
    }
    
    /// Observe viewDidAppear calls on current instance
    public func onViewDidAppear() -> Observable<Bool> {
        return ARViewControllerLifeCircleManager.instance.didAppear.filter{ [weak base] in $0.controller === base }.map{ $0.animated }
    }
    
    /// Observe viewWillDisappear calls on current instance
    public func onViewWillDisappear() -> Observable<Bool> {
        return ARViewControllerLifeCircleManager.instance.willDisappear.filter{ [weak base] in $0.controller === base }.map{ $0.animated }
    }
    
    /// Observe viewDidDisappear calls on current instance
    public func onViewDidDisappear() -> Observable<Bool> {
        return ARViewControllerLifeCircleManager.instance.didDisappear.filter{ [weak base] in $0.controller === base }.map{ $0.animated }
    }
}

public extension Reactive where Base: UIViewController {
    /// observe viewDidLoad calls on all instances of current type
    public static func onViewDidLoad() -> Observable<Base> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didLoad.subscribe(onNext: { vc in
                if let required = vc as? Base {
                    observer.onNext(required)
                }
            })
        })
    }
    
    /// observe viewWillAppear calls on all instances of current type
    public static func onViewWillAppear() -> Observable<(controller: Base, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willAppear.subscribe(onNext: { (vc, animated) in
                if let required = vc as? Base {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewDidAppear calls on all instances of current type
    public static func onViewDidAppear() -> Observable<(controller: Base, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didAppear.subscribe(onNext: { (vc, animated) in
                if let required = vc as? Base {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewWillDisappear calls on all instances of current type
    public static func onViewWillDisappear() -> Observable<(controller: Base, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.willDisappear.subscribe(onNext: { (vc, animated) in
                if let required = vc as? Base {
                    observer.onNext((required, animated))
                }
            })
        })
    }
    
    /// observe viewDidDisappear calls on all instances of current type
    public static func onViewDidDisappear() -> Observable<(controller: Base, animated: Bool)> {
        return Observable.create({ observer -> Disposable in
            return ARViewControllerLifeCircleManager.instance.didDisappear.subscribe(onNext: { (vc, animated) in
                if let required = vc as? Base {
                    observer.onNext((required, animated))
                }
            })
        })
    }
}

private class ARViewControllerLifeCircleManager {
    private static var __once: () = {
        swapMethods(#selector(UIViewController.viewDidLoad), swizzled: #selector(UIViewController.ar_viewDidLoad))
        swapMethods(#selector(UIViewController.viewWillAppear(_:)), swizzled: #selector(UIViewController.ar_viewWillAppear(_:)))
        swapMethods(#selector(UIViewController.viewDidAppear(_:)), swizzled: #selector(UIViewController.ar_viewDidAppear(_:)))
        swapMethods(#selector(UIViewController.viewWillDisappear(_:)), swizzled: #selector(UIViewController.ar_viewWillDisappear(_:)))
        swapMethods(#selector(UIViewController.viewDidDisappear(_:)), swizzled: #selector(UIViewController.ar_viewDidDisappear(_:)))
    }()
    static let instance : ARViewControllerLifeCircleManager = {
        _ = __once
        return ARViewControllerLifeCircleManager()
    }()
    fileprivate let didLoad = PublishSubject<UIViewController>()
    fileprivate let willAppear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let didAppear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let willDisappear = PublishSubject<(controller: UIViewController,animated: Bool)>()
    fileprivate let didDisappear = PublishSubject<(controller: UIViewController,animated: Bool)>()

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
