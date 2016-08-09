//
//  AppRouterReactiveTests.swift
//  AppRouter
//
//  Created by Antihevich on 8/9/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import XCTest
import RxSwift
@testable import AppRouter

class AppRouterReactiveTests: XCTestCase {
    
    func testDidLoad() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectationWithDescription("")
        let expectationTwo = expectationWithDescription("")
        _ = FirstController.onViewDidLoad().subscribeNext { _ in
            expectationOne.fulfill()
        }
        
        _ = first.onViewDidLoad().subscribeNext {
            expectationTwo.fulfill()
        }
        
        second.viewDidLoad()
        first.viewDidLoad()
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testWillAppear() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectationWithDescription("")
        let expectationTwo = expectationWithDescription("")
        _ = FirstController.onViewWillAppear().subscribeNext { (vc, animated) in
            XCTAssertTrue(animated)
            expectationOne.fulfill()
        }
        
        _ = first.onViewWillAppear().subscribeNext { animated in
            XCTAssertTrue(animated)
            expectationTwo.fulfill()
        }

        second.viewWillAppear(true)
        first.viewWillAppear(true)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testDidAppear() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectationWithDescription("")
        let expectationTwo = expectationWithDescription("")
        _ = FirstController.onViewDidAppear().subscribeNext { (vc, animated) in
            XCTAssertTrue(animated)
            expectationOne.fulfill()
        }
        
        _ = first.onViewDidAppear().subscribeNext { animated in
            XCTAssertTrue(animated)
            expectationTwo.fulfill()
        }
        
        second.viewDidAppear(true)
        first.viewDidAppear(true)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testWillDisappear() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectationWithDescription("")
        let expectationTwo = expectationWithDescription("")
        _ = FirstController.onViewWillDisappear().subscribeNext { (vc, animated) in
            XCTAssertTrue(animated)
            expectationOne.fulfill()
        }
        
        _ = first.onViewWillDisappear().subscribeNext { animated in
            XCTAssertTrue(animated)
            expectationTwo.fulfill()
        }
        
        second.viewWillDisappear(true)
        first.viewWillDisappear(true)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testDidDisappear() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectationWithDescription("")
        let expectationTwo = expectationWithDescription("")
        _ = FirstController.onViewDidDisappear().subscribeNext { (vc, animated) in
            XCTAssertTrue(animated)
            expectationOne.fulfill()
        }
        
        _ = first.onViewDidDisappear().subscribeNext { animated in
            XCTAssertTrue(animated)
            expectationTwo.fulfill()
        }
        
        second.viewDidDisappear(true)
        first.viewDidDisappear(true)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
