//
//  AppRouter+reactive.swift
//  AppRouter
//
//  Created by Antihevich on 8/9/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

#if os(OSX)
    import Cocoa
#if !RX_NO_MODULE
    import RxSwift
#endif
    
    public extension Reactive where Base: NSViewController {
        /// Observe viewDidLoad calls on current instance
        public func onViewDidLoad() -> Observable<Void> {
            return ARViewControllerLifeCycleManager.instance.didLoad.filter{ [weak base] in $0 === base }.map{ _ in () }
        }
        
        /// Observe viewWillAppear calls on current instance
        public func onViewWillAppear() -> Observable<Void> {
            return ARViewControllerLifeCycleManager.instance.willAppear.filter{ [weak base] in $0 === base }.map{ _ in () }
        }
        
        /// Observe viewDidAppear calls on current instance
        public func onViewDidAppear() -> Observable<Void> {
            return ARViewControllerLifeCycleManager.instance.didAppear.filter{ [weak base] in $0 === base }.map{ _ in () }
        }
        
        /// Observe viewWillDisappear calls on current instance
        public func onViewWillDisappear() -> Observable<Void> {
            return ARViewControllerLifeCycleManager.instance.willDisappear.filter{ [weak base] in $0 === base }.map{ _ in () }
        }
        
        /// Observe viewDidDisappear calls on current instance
        public func onViewDidDisappear() -> Observable<Void> {
            return ARViewControllerLifeCycleManager.instance.didDisappear.filter{ [weak base] in $0 === base }.map{ _ in () }
        }
    }
    
    public extension Reactive where Base: NSViewController {
        /// observe viewDidLoad calls on all instances of current type
        public static func onViewDidLoad() -> Observable<Base> {
            return Observable.create({ observer -> Disposable in
                return ARViewControllerLifeCycleManager.instance.didLoad.subscribe(onNext: { vc in
                    if let required = vc as? Base {
                        observer.onNext(required)
                    }
                })
            })
        }
        
        /// observe viewWillAppear calls on all instances of current type
        public static func onViewWillAppear() -> Observable<Base> {
            return Observable.create({ observer -> Disposable in
                return ARViewControllerLifeCycleManager.instance.willAppear.subscribe(onNext: { vc in
                    if let required = vc as? Base {
                        observer.onNext(required)
                    }
                })
            })
        }
        
        /// observe viewDidAppear calls on all instances of current type
        public static func onViewDidAppear() -> Observable<Base> {
            return Observable.create({ observer -> Disposable in
                return ARViewControllerLifeCycleManager.instance.didAppear.subscribe(onNext: { vc in
                    if let required = vc as? Base {
                        observer.onNext(required)
                    }
                })
            })
        }
        
        /// observe viewWillDisappear calls on all instances of current type
        public static func onViewWillDisappear() -> Observable<Base> {
            return Observable.create({ observer -> Disposable in
                return ARViewControllerLifeCycleManager.instance.willDisappear.subscribe(onNext: { vc in
                    if let required = vc as? Base {
                        observer.onNext(required)
                    }
                })
            })
        }
        
        /// observe viewDidDisappear calls on all instances of current type
        public static func onViewDidDisappear() -> Observable<Base> {
            return Observable.create({ observer -> Disposable in
                return ARViewControllerLifeCycleManager.instance.didDisappear.subscribe(onNext: { vc in
                    if let required = vc as? Base {
                        observer.onNext(required)
                    }
                })
            })
        }
    }
    
    private class ARViewControllerLifeCycleManager {
        private static var __once: () = {
            swapMethods(#selector(NSViewController.viewDidLoad), swizzled: #selector(NSViewController.ar_viewDidLoad))
            swapMethods(#selector(NSViewController.viewWillAppear), swizzled: #selector(NSViewController.ar_viewWillAppear))
            swapMethods(#selector(NSViewController.viewDidAppear), swizzled: #selector(NSViewController.ar_viewDidAppear))
            swapMethods(#selector(NSViewController.viewWillDisappear), swizzled: #selector(NSViewController.ar_viewWillDisappear))
            swapMethods(#selector(NSViewController.viewDidDisappear), swizzled: #selector(NSViewController.ar_viewDidDisappear))
        }()
        static let instance : ARViewControllerLifeCycleManager = {
            _ = __once
            return ARViewControllerLifeCycleManager()
        }()
        fileprivate let didLoad = PublishSubject<NSViewController>()
        fileprivate let willAppear = PublishSubject<NSViewController>()
        fileprivate let didAppear = PublishSubject<NSViewController>()
        fileprivate let willDisappear = PublishSubject<NSViewController>()
        fileprivate let didDisappear = PublishSubject<NSViewController>()
        
        fileprivate class func swapMethods(_ original: Selector, swizzled: Selector) {
            guard let originalMethod = class_getInstanceMethod(NSViewController.self, original),
                let swizzledMethod = class_getInstanceMethod(NSViewController.self, swizzled) else { return }
            let didAddMethod = class_addMethod(NSViewController.self, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            if didAddMethod { class_replaceMethod(NSViewController.self, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) }
            else { method_exchangeImplementations(originalMethod, swizzledMethod) }
        }
    }
    
    extension NSViewController {
        @objc fileprivate func ar_viewDidLoad() -> () {
            self.ar_viewDidLoad()
            ARViewControllerLifeCycleManager.instance.didLoad.onNext(self)
        }
        @objc fileprivate func ar_viewWillAppear() -> () {
            self.ar_viewWillAppear()
            ARViewControllerLifeCycleManager.instance.willAppear.onNext(self)
        }
        @objc fileprivate func ar_viewDidAppear() -> () {
            self.ar_viewDidAppear()
            ARViewControllerLifeCycleManager.instance.didAppear.onNext(self)
        }
        @objc fileprivate func ar_viewWillDisappear() -> () {
            self.ar_viewWillDisappear()
            ARViewControllerLifeCycleManager.instance.willDisappear.onNext(self)
        }
        @objc fileprivate func ar_viewDidDisappear() -> () {
            self.ar_viewDidDisappear()
            ARViewControllerLifeCycleManager.instance.didDisappear.onNext(self)
        }
    }
    
#endif

