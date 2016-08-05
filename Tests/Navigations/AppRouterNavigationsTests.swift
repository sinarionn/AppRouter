//
//  AppRouterNavigationsTests.swift
//  AppRouter
//
//  Created by Antihevich on 8/5/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import XCTest
@testable import AppRouter

class AppRouterNavigationsTests: XCTestCase {
    
    override func setUp() {
        AppRouter.rootViewController = nil
    }
    
    func testTabBarSelectedChange() {
        let tabBar = UITabBarController()
        let nav = NavigationControllerWithExpectations()
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        nav.viewControllers = [first]
        tabBar.viewControllers = [nav, second]
        
        XCTAssertTrue(tabBar.selectedViewController == nav)
        XCTAssertTrue(tabBar.setSelectedViewController(AppRouterPresenterAdditionalController))
        XCTAssertTrue(tabBar.selectedViewController == second)
        XCTAssertTrue(tabBar.setSelectedViewController(AppRouterPresenterBaseController))
        XCTAssertTrue(tabBar.selectedViewController == nav)
        XCTAssertFalse(tabBar.setSelectedViewController(AppRouterPresenterTabBarController))
    }
    
    func testNavAccessors() {
        let nav = UINavigationController()
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        nav.viewControllers = [first, second]
        AppRouter.rootViewController = nav
        
        let expectation =  expectationWithDescription("")
        NSOperationQueue.mainQueue().addOperationWithBlock {
            guard let popped = nav.popToViewController(AppRouterPresenterBaseController.self, animated: false) else { return XCTFail() }
            XCTAssertTrue(popped.count == 1)
            XCTAssertNotNil(popped.first == second)
            expectation.fulfill()
        }
        
        XCTAssertTrue(nav.topViewController == second)
        XCTAssertNil(nav.popToViewController(AppRouterPresenterTabBarController.self, animated: false))
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testPopFromTop() {
        let nav = UINavigationController()
        let first = AppRouterPresenterBaseController()
        let second = AppRouterPresenterAdditionalController()
        nav.viewControllers = [first, second]
        AppRouter.rootViewController = nav

        XCTAssertTrue(AppRouter.topViewController == second)
        let expectation =  expectationWithDescription("")
        AppRouter.popFromTopNavigation(animated: false, completion: {
            XCTAssertTrue(AppRouter.topViewController == first)
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testPopViewControllerAnimated() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        let third = ThirdController()

        XCTAssertNil(nav.popViewController(animated: true, completion: { XCTFail() }))
        
        nav.viewControllers = [first]
        XCTAssertNil(first.pop(animated: true, completion: { XCTFail() }))
        
        nav.viewControllers = [first, second, third]
        XCTAssertNil(first.pop(animated: true, completion: { XCTFail() }))
        
        AppRouter.rootViewController = nav
        let expectation =  expectationWithDescription("")
        delay(0) {
            var popped : [UIViewController]? = []
            popped = second.pop(animated: true) {
                XCTAssertTrue(popped?.first == second)
                XCTAssertTrue(popped?.last == third)
                XCTAssertNil(first.pop(animated: false))
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testPopViewController() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        let third = ThirdController()

        XCTAssertNil(nav.popViewController(animated: false, completion: { XCTFail() }))
        
        nav.viewControllers = [first]
        XCTAssertNil(first.pop(animated: false, completion: { XCTFail() }))
        
        nav.viewControllers = [first, second, third]
        XCTAssertNil(first.pop(animated: true, completion: { XCTFail() }))
        
        AppRouter.rootViewController = nav
        let expectation =  expectationWithDescription("")
        var popped : [UIViewController]? = []
        popped = second.pop(animated: false) {
            delay(0) {
                XCTAssertTrue(popped?.first == second)
                XCTAssertTrue(popped?.last == third)
                XCTAssertNil(first.pop(animated: false))
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testPopGenericViewControllerAnimated() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        let third = ThirdController()

        nav.viewControllers = [first, second, third]
        XCTAssertNil(nav.popToViewController(UITabBarController.self, animated: true, completion: { XCTFail() }))
        
        AppRouter.rootViewController = nav
        let expectation =  expectationWithDescription("")
        delay(0) {
            var popped : [UIViewController]? = []
            popped = nav.popToViewController(FirstController.self, animated: true) {
                XCTAssertTrue(popped?.first == second)
                XCTAssertTrue(popped?.last == third)
                XCTAssertTrue(nav.viewControllers.last == first)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testPopGenericViewController() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        let third = ThirdController()
        
        nav.viewControllers = [first, second, third]
        XCTAssertNil(nav.popToViewController(UITabBarController.self, animated: false, completion: { XCTFail() }))
        
        AppRouter.rootViewController = nav
        let expectation =  expectationWithDescription("")
        var popped : [UIViewController]? = []
        popped = nav.popToViewController(FirstController.self, animated: false) {
            delay(0){
                XCTAssertTrue(popped?.first == second)
                XCTAssertTrue(popped?.last == third)
                XCTAssertTrue(nav.viewControllers.last == first)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testPopToRootViewControllerAnimated() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        let third = ThirdController()
        
        nav.viewControllers = [first, second, third]
        
        AppRouter.rootViewController = nav
        let expectation =  expectationWithDescription("")
        delay(0) {
            var popped : [UIViewController]? = []
            popped = nav.popToRootViewController(animated: true) {
                XCTAssertTrue(popped?.first == second)
                XCTAssertTrue(popped?.last == third)
                XCTAssertTrue(nav.viewControllers.last == first)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testPopToRootViewController() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        let third = ThirdController()
        
        nav.viewControllers = [first, second, third]
        AppRouter.rootViewController = nav

        let expectation =  expectationWithDescription("")
        var popped : [UIViewController]? = []
        popped = nav.popToRootViewController(animated: false) {
            delay(0){
                XCTAssertTrue(popped?.first == second)
                XCTAssertTrue(popped?.last == third)
                XCTAssertTrue(nav.viewControllers.last == first)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testCloseViewControllerAnimated() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        let third = ThirdController()
        
        nav.viewControllers = [first, second]
        AppRouter.rootViewController = nav
        second.presentViewController(third, animated: false, completion: nil)

        let expectation = expectationWithDescription("")
        delay(0) {
            XCTAssertTrue(third.close(){
                XCTAssertNil(third.presentingViewController)
                XCTAssertTrue(second.close(){
                    XCTAssertTrue(nav.topViewController == first)
                    XCTAssertFalse(nav.close())
                    expectation.fulfill()
                })
            })
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testCloseViewController() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        let third = ThirdController()
        
        nav.viewControllers = [first, second]
        AppRouter.rootViewController = nav
        second.presentViewController(third, animated: false, completion: nil)
        
        let expectation = expectationWithDescription("")
        delay(0) {
            XCTAssertTrue(third.close(animated: false){
                XCTAssertNil(third.presentingViewController)
                XCTAssertTrue(second.close(animated: false){
                    XCTAssertTrue(nav.topViewController == first)
                    XCTAssertFalse(nav.close(animated: false))
                    expectation.fulfill()
                })
            })
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testPushOnNavigationController() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        
        nav.viewControllers = [first]
        AppRouter.rootViewController = nav
        let expectation = expectationWithDescription("")
        
        delay(0) {
            nav.pushViewController(second, animated: false) {
                XCTAssertTrue(nav.viewControllers.last == second)
                nav.pushViewController(second, animated: false, completion: { 
                    XCTFail()
                })
                delay(0.1) {
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testPushOnNavigationControllerAnimated() {
        let nav = UINavigationController()
        let first = FirstController()
        let second = SecondController()
        
        nav.viewControllers = [first]
        AppRouter.rootViewController = nav
        let expectation = expectationWithDescription("")
        
        delay(0) {
            nav.pushViewController(second, animated: true) {
                XCTAssertTrue(nav.viewControllers.last == second)
                nav.pushViewController(second, animated: true, completion: {
                    XCTFail()
                })
                delay(0.5) {
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(4, handler: nil)
    }

}

internal func delay(delay:Double, _ closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
    