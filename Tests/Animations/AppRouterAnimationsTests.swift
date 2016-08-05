//
//  AppRouterAnimationsTests.swift
//  AppRouter
//
//  Created by Antihevich on 8/5/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import XCTest
@testable import AppRouter

class AppRouterAnimationsTests: XCTestCase {
    
    override func setUp() {
        AppRouter.rootViewController = nil
    }
    
    func testViewAnimation() {
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        
        AppRouter.animations.setRootWithViewAnimation(first, duration: 0)
        XCTAssertTrue(AppRouter.rootViewController == first)
        
        let expectation =  expectationWithDescription("")
        AppRouter.animations.setRootWithViewAnimation(second, duration: 0, callback: { _ in
            XCTAssertTrue(AppRouter.rootViewController == second)
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testWindowAnimation() {
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        
        AppRouter.animations.setRootWithWindowAnimation(first, duration: 0)
        XCTAssertTrue(AppRouter.rootViewController == first)
        
        let expectation =  expectationWithDescription("")
        AppRouter.animations.setRootWithWindowAnimation(second, duration: 0, callback: { _ in
            XCTAssertTrue(AppRouter.rootViewController == second)
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSnapshotAnimation() {
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        
        AppRouter.animations.setRootWithSnapshotAnimation(first, duration: 0)
        XCTAssertTrue(AppRouter.rootViewController == first)
        
        let expectation =  expectationWithDescription("")
        AppRouter.animations.setRootWithSnapshotAnimation(second, duration: 0, callback: { _ in
            XCTAssertTrue(AppRouter.rootViewController == second)
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}