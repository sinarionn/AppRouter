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
        controller.viewDidLoadExpectation = expectation(description: "viewDidLoad should be called")
        _ = controller.view
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInstantiateFromStoryboardWithDefaultParameters() {
        let controller = StoryboardWithInitialViewController.instantiate()!
        controller.viewDidLoadExpectation = expectation(description: "viewDidLoad should be called")
        _ = controller.view
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInstantiateFromStoryboardWithInitialParameter() {
        let controller = StoryboardWithInitialViewController.instantiate(initial: true)!
        controller.viewDidLoadExpectation = expectation(description: "viewDidLoad should be called")
        _ = controller.view
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInstantiateFromStoryboardInitialSkippingNavigation() {
        let controller = StoryboardWithInitialNavigationViewController.instantiate(initial: true)!
        controller.viewDidLoadExpectation = expectation(description: "viewDidLoad should be called")
        _ = controller.view
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInstantiateFromXib() {
        let controller = XibWithViewController.instantiateFromXib()
        controller?.viewDidLoadExpectation = expectation(description: "viewDidLoad should be called")
        _ = controller?.view
        waitForExpectations(timeout: 1, handler: nil)
    }
}
