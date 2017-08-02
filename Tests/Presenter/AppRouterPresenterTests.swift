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
    weak var tabBarController: AppRouterPresenterTabBarController!
    weak var navController: AppRouterPresenterNavigationController!
    weak var baseController: AppRouterPresenterBaseController!
    
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
        XCTAssertTrue(try UIViewController.presenter().onTop().performTargetConstruction() == baseController)
        XCTAssertTrue(try UIViewController.presenter().onRoot().performTargetConstruction() == tabBarController)
        XCTAssertTrue(try UIViewController.presenter().on{ self.baseController }.performTargetConstruction() == baseController)
    }
    
    func testPresenterUtilitySourceMethods() {
        XCTAssertNotNil(try AppRouterPresenterAdditionalController.presenter().fromXib().performSourceConstruction())
        XCTAssertNotNil(try AppRouterPresenterAdditionalController.presenter().fromXib("AppRouterPresenterAdditionalController").performSourceConstruction())
        XCTAssertNotNil(try AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false).performSourceConstruction())
        XCTAssertNotNil(try StoryboardWithInitialViewController.presenter().fromStoryboard().performSourceConstruction())
    }

    func testPresenterUtilityConfigurationMethods() {
        XCTAssertFalse(try baseController.presenter().provideSourceController().initialized)
        XCTAssertTrue(try baseController.presenter().configure({ $0.initialized = true }).provideSourceController().initialized)
    }
    
    func testPresenterProvideSourceController() throws {
        XCTAssertFalse(baseController.initialized)
        let presenter = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false).configure({ $0.initialized = true })
        XCTAssertTrue(try presenter.provideSourceController().initialized == true)
    }
    
    func testPresenterProvideEmbeddedSourceController() throws {
        XCTAssertFalse(baseController.initialized)
        let nav = UINavigationController()
        let presenter = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false)
            .configure({
                $0.initialized = true
                $0.navigationController?.title = "TestTitle"
            }).embedInNavigation(nav)
        
        let embedded = try presenter.provideEmbeddedSourceController()
        XCTAssertTrue(embedded.parent === nav)
        guard let embeddedNav = embedded.parent as? UINavigationController else { return XCTFail() }
        guard let visible = embeddedNav.visibleViewController as? AppRouterPresenterAdditionalController else { return XCTFail() }
        XCTAssertTrue(visible.initialized == true)
        XCTAssertTrue(embeddedNav.title == "TestTitle")
        XCTAssertTrue(embedded.child === visible)
    }
    
    func testPresenterUtilityEmbedInNavigation() throws {
        let controller = AppRouterPresenterAdditionalController()
        let presenter = controller.presenter().embedInNavigation()
        let embed = try presenter.provideEmbeddedSourceController()
        guard let navigation = embed.parent as? UINavigationController else { return XCTFail() }
        XCTAssertTrue(navigation.topViewController == controller)
    }
    
    func testPresenterUtilityEmbedInCustomNavigation() throws {
        let controller = AppRouterPresenterAdditionalController()
        let navigation = UINavigationController()
        let presenter = controller.presenter().embedInNavigation(navigation)
        let embed = try presenter.provideEmbeddedSourceController()
        guard let nav = embed.parent as? UINavigationController else { return XCTFail() }
        XCTAssertTrue(navigation.topViewController == controller)
        XCTAssertTrue(nav == navigation)
        XCTAssertTrue(embed.child == controller)
    }
    
    func testPresenterUtilityEmbedInCustomTabBar() throws {
        let controller = AppRouterPresenterAdditionalController()
        let tabBar = UITabBarController()
        let presenter = controller.presenter().embedInTabBar(tabBar)
        let embed = try presenter.provideEmbeddedSourceController()
        guard let tab = embed.parent as? UITabBarController else { return XCTFail() }
        XCTAssertTrue(tab.viewControllers?.last == controller)
        XCTAssertTrue(tab == tabBar)
        XCTAssertTrue(embed.child == controller)
    }
    
    func testPresenterUtilityEmbedInCustomProvider() {
        let controller = AppRouterPresenterAdditionalController()
        XCTAssertTrue(try controller.presenter().embedIn({ $0 }).provideEmbeddedSourceController().parent == controller)
    }
    
    func testPresenterUtilityCustom() throws {
        let customPresenter = AppRouterPresenterAdditionalController.presenter()
            .fromStoryboard("AppRouterPresenterControllers", initial: false)
            .embedIn({ self.navController?.viewControllers = [$0]; return self.navController })
            .configure({ $0.initialized = true })
        guard let embeddedController = try customPresenter.provideEmbeddedSourceController().parent as? AppRouterPresenterNavigationController else { return XCTFail() }
        XCTAssertTrue(embeddedController == navController)
        XCTAssertTrue((embeddedController.topViewController as? AppRouterPresenterAdditionalController)?.initialized == true)
        XCTAssertNil(try? AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterInstantiationsTests", initial: true).provideEmbeddedSourceController())
    }
    
    func testPresenterPresent() throws {
        XCTAssertTrue(AppRouter.topViewController == baseController)
        let presented = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false).configure({ $0.initialized = true }).present(animated: false)
        XCTAssertTrue(AppRouter.topViewController == presented)
        XCTAssertTrue(baseController?.presentedViewController == presented)
        XCTAssertTrue(presented?.initialized == true)
        XCTAssertNil(AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterInstantiationsTests", initial: true).present())
    }
    
    func testPresenterPush() throws {
        XCTAssertTrue(AppRouter.topViewController == baseController)
        let pushed = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false).configure({ $0.initialized = true }).push(animated: false)
        XCTAssertTrue(AppRouter.topViewController == pushed)
        XCTAssertTrue(pushed?.navigationController == navController)
        XCTAssertTrue(pushed?.initialized == true)
        XCTAssertNil(AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterInstantiationsTests").push())
    }
    
    func testPresenterSetAsRoot() throws {
        XCTAssertTrue(AppRouter.topViewController == baseController)
        let presented = AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterPresenterControllers", initial: false).configure({ $0.initialized = true }).setAsRoot(animation: .none)
        XCTAssertTrue(AppRouter.rootViewController == presented)
        XCTAssertTrue(presented?.initialized == true)
        XCTAssertNil(AppRouterPresenterAdditionalController.presenter().fromStoryboard("AppRouterInstantiationsTests", initial: true).setAsRoot())
    }
    
    func testPresenterOnInstance() {
        let controller = UIViewController()
        XCTAssertTrue(try controller.presenter().provideSourceController() == controller)
    }
}
