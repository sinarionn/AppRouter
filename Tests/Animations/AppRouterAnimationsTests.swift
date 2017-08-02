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
        AppRouter.shared.rootViewController = nil
    }
    
    func testViewAnimation() {
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        
        AppRouter.shared.animator.setRootWithViewAnimation(first, duration: 0)
        XCTAssertTrue(AppRouter.rootViewController == first)
        
        let expectation =  self.expectation(description: "")
        AppRouter.shared.animator.setRootWithViewAnimation(second, duration: 0, callback: { _ in
            XCTAssertTrue(AppRouter.rootViewController == second)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWindowAnimation() {
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        
        AppRouter.shared.animator.setRootWithWindowAnimation(first, duration: 0)
        XCTAssertTrue(AppRouter.rootViewController == first)
        
        let expectation =  self.expectation(description: "")
        AppRouter.shared.animator.setRootWithWindowAnimation(second, duration: 0, callback: { _ in
            XCTAssertTrue(AppRouter.rootViewController == second)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSnapshotAnimation() {
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        
        AppRouter.shared.animator.setRootWithSnapshotAnimation(first, duration: 0)
        XCTAssertTrue(AppRouter.rootViewController == first)
        
        let expectation =  self.expectation(description: "")
        AppRouter.shared.animator.setRootWithSnapshotAnimation(second, duration: 0, callback: { _ in
            XCTAssertTrue(AppRouter.rootViewController == second)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
}
