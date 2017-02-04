//
//  AppRouterPresenterTests.swift
//  AppRouter
//
//  Created by Antihevich on 8/5/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import XCTest
@testable import AppRouter

class AppRouterPresenterTests: XCTestCase {
    weak var tabBarController: AppRouterPresenterTabBarController?
    weak var navController: AppRouterPresenterNavigationController?
    weak var baseController: AppRouterPresenterBaseController?
    
    override func setUp() {
        tabBarController = AppRouterPresenterTabBarController.instantiate(storyboardName: "AppRouterPresenterControllers", initial: true)
        navController = tabBarController?.viewControllers?.first as? AppRouterPresenterNavigationController
        baseController = navController?.viewControllers.first as? AppRouterPresenterBaseController
        
        AppRouter.rootViewController = tabBarController
    }
    
    func testInitialization() {
        XCTAssertNotNil(tabBarController)
        XCTAssertNotNil(navController)
        XCTAssertNotNil(baseController)
    }
    
    func testPresenterUtilityTargetMethods() {
        let presenter = UIViewController.presenter()
        _ = presenter.onTop()
        XCTAssertTrue(presenter.target.provideController(UIViewController.self) == baseController)
        _ = presenter.onRoot()
        XCTAssertTrue(presenter.target.provideController(UIViewController.self) == tabBarController)
        _ = presenter.onCustom({ self.baseController })
        XCTAssertTrue(presenter.target.provideController(UIViewController.self) == baseController)
    }
    
    func testPresenterUtilitySourceMethods() {
        let presenter = AppRouterPresenterAdditionalController.presenter()
        _ = presenter.fromXib()
        XCTAssertNotNil(presenter.source.provideController(AppRouterPresenterAdditionalController.self))
        _ = presenter.fromXib("AppRouterPresenterAdditionalController")
        XCTAssertNotNil(presenter.source.provideController(AppRouterPresenterAdditionalController.self))
        _ = presenter.fromStoryboard("AppRouterPresenterControllers", initial: false)
        XCTAssertNotNil(presenter.source.provideController(AppRouterPresenterAdditionalController.self))
        
        let initialPresenter = StoryboardWithInitialViewController.presenter()
        _ = initialPresenter.fromStoryboard()
        XCTAssertNotNil(initialPresenter.source.provideController(StoryboardWithInitialViewController.self))
    }
    
    func testPresenterUtilityConfigurationMethods() {
        let presenter = AppRouterPresenterBaseController.presenter()
        guard let base = baseController else { return XCTFail() }
        presenter.configurator(base)
        XCTAssertFalse(base.initialized)
        _ = presenter.configure({ $0.initialized = true })
        presenter.configurator(base)
        XCTAssertTrue(base.initialized)
    }
    
    func testPresenterProvideSourceController() {
        let presenter = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false)
        guard let base = baseController else { return XCTFail() }
        XCTAssertFalse(base.initialized)
        _ = presenter.configure({ $0.initialized = true })
        let source = presenter.provideSourceController()
        XCTAssertTrue(source?.initialized == true)
    }
    
    func testPresenterProvideEmbeddedSourceController() {
        let presenter = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false)
        let nav = UINavigationController()
        guard let base = baseController else { return XCTFail() }
        XCTAssertFalse(base.initialized)
        _ = presenter.configure({
            $0.initialized = true
            $0.navigationController?.title = "TestTitle"
        }).embedInNavigation(nav)
        let embedded = presenter.provideEmbeddedSourceController()
        XCTAssertTrue(embedded === nav)
        guard let embeddedNav = embedded as? UINavigationController else { return XCTFail() }
        guard let first = embeddedNav.visibleViewController as? AppRouterPresenterAdditionalController else { return XCTFail() }
        XCTAssertTrue(first.initialized == true)
        XCTAssertTrue(embeddedNav.title == "TestTitle")
    }
    
    func testPresenterUtilityEmbeddingMethods() {
        let presenter = AppRouterPresenterAdditionalController.presenter()
        let controller = AppRouterPresenterAdditionalController()
        _ = presenter.embedInNavigation()
        guard let navigation = presenter.embedder(controller) as? UINavigationController else { return XCTFail() }
        XCTAssertTrue(navigation.topViewController == controller)
        
        guard let customNavigation = navController else { return XCTFail() }
        _ = presenter.embedInNavigation(customNavigation)
        guard let embeddedCustom = presenter.embedder(controller) as? UINavigationController else { return XCTFail() }
        XCTAssertTrue(embeddedCustom is AppRouterPresenterNavigationController)
        XCTAssertTrue(embeddedCustom.topViewController == controller)
        
        
        guard let customTabBar = tabBarController else { return XCTFail() }
        _ = presenter.embedInTabBar(customTabBar)
        guard let embeddedCustomTabBar = presenter.embedder(controller) as? UITabBarController else { return XCTFail() }
        XCTAssertTrue(embeddedCustomTabBar is AppRouterPresenterTabBarController)
        XCTAssertTrue(embeddedCustomTabBar.viewControllers?.last == controller)
        
        _ = presenter.embedIn({ $0 })
        XCTAssertTrue(presenter.embedder(controller) == controller)
        
        let customPresenter = AppRouterPresenterAdditionalController.presenter()
            .fromStoryboard("AppRouterPresenterControllers", initial: false)
            .embedIn({ self.navController?.viewControllers = [$0]; return self.navController })
            .configure({ $0.initialized = true })
        guard let embeddedController = customPresenter.provideEmbeddedSourceController() as? AppRouterPresenterNavigationController else { return XCTFail() }
        XCTAssertTrue(embeddedController == navController)
        XCTAssertTrue((embeddedController.topViewController as? AppRouterPresenterAdditionalController)?.initialized == true)
        XCTAssertNil(AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterInstantiationsTests", initial: true).provideEmbeddedSourceController())
    }
    
    func testPresenterPresent() {
        XCTAssertTrue(AppRouter.topViewController == baseController)
        guard let presented = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false).configure({ $0.initialized = true }).present(animated: false) else { return XCTFail() }
        XCTAssertTrue(AppRouter.topViewController == presented)
        XCTAssertTrue(baseController?.presentedViewController == presented)
        XCTAssertTrue(presented.initialized)
        XCTAssertNil(AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterInstantiationsTests", initial: true).present())
    }
    
    func testPresenterPush() {
        XCTAssertTrue(AppRouter.topViewController == baseController)
        guard let pushed = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false).configure({ $0.initialized = true }).push(animated: false) else { return XCTFail() }
        XCTAssertTrue(AppRouter.topViewController == pushed)
        XCTAssertTrue(pushed.navigationController == navController)
        XCTAssertTrue(pushed.initialized)        
        XCTAssertNil(AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterInstantiationsTests").push())
    }
    
    func testPresenterOnInstance() {
        let controller = UIViewController()
        XCTAssertTrue(controller.presenter().provideSourceController() == controller)
    }
}
