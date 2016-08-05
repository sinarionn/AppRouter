//
//  AppRouterInstantiationsTests.swift
//  AppRouter
//
//  Created by Prokhor Kharchenko on 6/23/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import XCTest
@testable import AppRouter

class AppRouterInstantiationsTests: XCTestCase {

    func testInstantiateFromStoryboardWithStoryboardName() {
        let controller = AppRouterInstantiationsTestsViewController.instantiate(storyboardName: "AppRouterInstantiationsTests")!
        controller.viewDidLoadExpectation = expectationWithDescription("viewDidLoad should be called")
        _ = controller.view
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testInstantiateFromStoryboardWithDefaultParameters() {
        let controller = StoryboardWithInitialViewController.instantiate()!
        controller.viewDidLoadExpectation = expectationWithDescription("viewDidLoad should be called")
        _ = controller.view
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testInstantiateFromStoryboardWithInitialParameter() {
        let controller = StoryboardWithInitialViewController.instantiate(initial: true)!
        controller.viewDidLoadExpectation = expectationWithDescription("viewDidLoad should be called")
        _ = controller.view
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testInstantiateFromStoryboardInitialSkippingNavigation() {
        let controller = StoryboardWithInitialNavigationViewController.instantiate(initial: true)!
        controller.viewDidLoadExpectation = expectationWithDescription("viewDidLoad should be called")
        _ = controller.view
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testInstantiateInsideNavigationFromStoryboardWithInitialViewController() {
        let navigationController = StoryboardWithInitialNavigationController.instantiateInsideNavigation(initial: true)!
        let controller = navigationController.viewControllers.first as! StoryboardWithInitialNavigationController
        controller.viewDidLoadExpectation = expectationWithDescription("viewDidLoad should be called")
        _ = controller.view
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testInstantiateFromXib() {
        let controller = XibWithViewController.instantiateFromXib()
        controller?.viewDidLoadExpectation = expectationWithDescription("viewDidLoad should be called")
        _ = controller?.view
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
