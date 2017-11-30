//
//  AppRouterReactiveTests.swift
//  AppRouter
//
//  Created by Antihevich on 8/9/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import XCTest
import RxSwift
import AppRouterRx

class AppRouterReactiveTests: XCTestCase {
    
    func testDidLoad() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectation(description: "")
        let expectationTwo = expectation(description: "")
        _ = FirstController.rx.onViewDidLoad().subscribe(onNext: { _ in
            expectationOne.fulfill()
        })
        
        _ = first.rx.onViewDidLoad().subscribe(onNext: {
            expectationTwo.fulfill()
        })
        
        second.viewDidLoad()
        first.viewDidLoad()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testWillAppear() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectation(description: "")
        let expectationTwo = expectation(description: "")
        _ = FirstController.rx.onViewWillAppear().subscribe(onNext: { (vc, animated) in
            XCTAssertTrue(animated)
            expectationOne.fulfill()
        })
        
        _ = first.rx.onViewWillAppear().subscribe(onNext: { animated in
            XCTAssertTrue(animated)
            expectationTwo.fulfill()
        })

        second.viewWillAppear(true)
        first.viewWillAppear(true)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidAppear() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectation(description: "")
        let expectationTwo = expectation(description: "")
        _ = FirstController.rx.onViewDidAppear().subscribe(onNext: { (vc, animated) in
            XCTAssertTrue(animated)
            expectationOne.fulfill()
        })
        
        _ = first.rx.onViewDidAppear().subscribe(onNext: { animated in
            XCTAssertTrue(animated)
            expectationTwo.fulfill()
        })
        
        second.viewDidAppear(true)
        first.viewDidAppear(true)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testWillDisappear() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectation(description: "")
        let expectationTwo = expectation(description: "")
        _ = FirstController.rx.onViewWillDisappear().subscribe(onNext: { (vc, animated) in
            XCTAssertTrue(animated)
            expectationOne.fulfill()
        })
        
        _ = first.rx.onViewWillDisappear().subscribe(onNext: { animated in
            XCTAssertTrue(animated)
            expectationTwo.fulfill()
        })
        
        second.viewWillDisappear(true)
        first.viewWillDisappear(true)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidDisappear() {
        let first = FirstController()
        let second = SecondController()
        let expectationOne = expectation(description: "")
        let expectationTwo = expectation(description: "")
        _ = FirstController.rx.onViewDidDisappear().subscribe(onNext: { (vc, animated) in
            XCTAssertTrue(animated)
            expectationOne.fulfill()
        })
        
        _ = first.rx.onViewDidDisappear().subscribe(onNext: { animated in
            XCTAssertTrue(animated)
            expectationTwo.fulfill()
        })
        
        second.viewDidDisappear(true)
        first.viewDidDisappear(true)
        waitForExpectations(timeout: 2, handler: nil)
    }
}
