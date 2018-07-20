//
//  AppRouterRouteTests.swift
//  Tests
//
//  Created by Artem Antihevich on 7/20/18.
//  Copyright © 2018 Artem Antihevich. All rights reserved.
//

import XCTest
import AppRouterRoute
import ReusableView
import RxSwift
import RxCocoa
import Dip

class AppRouterRouteTests: XCTestCase {
    var disposeBag: DisposeBag!
    var route: Route<TestableController>!
    var factory: VirtualFactory!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        factory = VirtualFactory()
        route = Route(viewFactory: factory, viewModelFactory: factory).from(provider: TestableController.init)
    }
    
    func testBuildView() {
        let vc = TestableController()
        factory.buildViewReturn = vc
        XCTAssertEqual(try route.fromFactory().provideSourceController(), vc)
    }
    
    func testBuildViewArg() {
        let vc = TestableController()
        factory.buildViewArgReturn = vc
        XCTAssertEqual(try route.fromFactory(arg: 123).provideSourceController(), vc)
        XCTAssertEqual(factory.buildViewArgReceived as? Int, 123)
    }
    
    func testBuildViewModel() {
        factory.buildViewModelReturn = "123"
        XCTAssertEqual(try route.buildViewModel().provideSourceController().viewModel, "123")
    }
    
    func testBuildViewModelArg() {
        factory.buildViewModelArgReturn = "123"
        XCTAssertEqual(try route.buildViewModel(111).provideSourceController().viewModel, "123")
        XCTAssertEqual(factory.buildViewModelArgReceived as? Int, 111)
    }
    
    func testBuildViewModelArgArg() {
        factory.buildViewModelArgArgReturn = "123"
        XCTAssertEqual(try route.buildViewModel(111, "abc").provideSourceController().viewModel, "123")
        XCTAssertEqual(factory.buildViewModelArgArgReceived?.0 as? Int, 111)
        XCTAssertEqual(factory.buildViewModelArgArgReceived?.1 as? String, "abc")
    }
    
    func testBuildViewModelArgArgArg() {
        factory.buildViewModelArgArgArgReturn = "123"
        XCTAssertEqual(try route.buildViewModel(111, "abc", 3.14).provideSourceController().viewModel, "123")
        XCTAssertEqual(factory.buildViewModelArgArgArgReceived?.0 as? Int, 111)
        XCTAssertEqual(factory.buildViewModelArgArgArgReceived?.1 as? String, "abc")
        XCTAssertEqual(factory.buildViewModelArgArgArgReceived?.2 as? Double, 3.14)
    }
    
    func testBuildMoreArgumentsBecomesTuple() throws {
        factory.buildViewModelArgReturn = "123"
        XCTAssertEqual(try route.buildViewModel((1, 2, 3, 4, 5)).provideSourceController().viewModel, "123")
        let args = try factory.buildViewModelArgReceived as? (Int,Int,Int,Int,Int) ?? "Wrong tuple type".rethrow()
        XCTAssertEqual(args.0, 1)
        XCTAssertEqual(args.1, 2)
        XCTAssertEqual(args.2, 3)
        XCTAssertEqual(args.3, 4)
        XCTAssertEqual(args.4, 5)
    }
    
    func testWithSpecificViewModel() {
        XCTAssertEqual(try route.with(viewModel: "321").provideSourceController().viewModel, "321")
    }
}

class AppRouterRouteRxUtitlityTests: XCTestCase {
    var disposeBag: DisposeBag!
    var route: TestableRoute<TestableController>!
    var factory: VirtualFactory!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        factory = VirtualFactory()
        route = TestableRoute(viewFactory: factory, viewModelFactory: factory)
    }
    func testRxUtilityPresent() {
        Observable.just(route).present().disposed(by: disposeBag)
        XCTAssertTrue(route.presentWasCalled)
    }
    func testRxUtilityPush() {
        Observable.just(route).push().disposed(by: disposeBag)
        XCTAssertTrue(route.pushWasCalled)
    }
    func testRxUtilitySetAsRoot() {
        Observable.just(route).setAsRoot().disposed(by: disposeBag)
        XCTAssertTrue(route.setAsRootWasCalled)
    }
    func testRxUtilityShow() {
        Observable.just(route).show().disposed(by: disposeBag)
        XCTAssertTrue(route.showWasCalled)
    }
    func testRxUtilityPushOn() {
        let vc = UIViewController()
        Observable.just(route).push(on: vc).disposed(by: disposeBag)
        XCTAssertTrue(route.pushWasCalled)
        XCTAssertTrue(route.onWasCalled)
        XCTAssertEqual(try route.onProviderReceived(), vc)
    }
}

class ViewFactoryTests: XCTestCase {
    let container = DependencyContainer()
    
    override func tearDown() {
        super.tearDown()
        container.reset()
    }
    
    func testBuildView() {
        do {
            let vc = try container.buildView() as ViewFactoryTestableViewController
            XCTAssertNotNil(vc)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    func testBuildViewWithArg() {
        do {
            let vc = try container.buildView(arg: "234") as ViewFactoryTestableViewController
            XCTAssertNotNil(vc)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    func testThrowsErrorOnControllerWithoutOwnStoryboard() {
        XCTAssertThrowsError(try container.buildView() as AppRouterInstantiationsTestsViewController)
    }
}


class TestableController: UIViewController, ReusableType {
    var viewModelReceived: String!
    func onUpdate(with viewModel: String, reuseBag: DisposeBag) {
        viewModelReceived = viewModel
    }
}

class TestableRoute<T: UIViewController>: Route<T> where T: ViewModelHolderType {
    var presentWasCalled = false
    var pushWasCalled = false
    var setAsRootWasCalled = false
    var showWasCalled = false
    
    override func present() throws -> T {
        presentWasCalled = true
        throw "Error"
    }
    
    override func push() throws -> T {
        pushWasCalled = true
        throw "Error"
    }
    
    override func setAsRoot() throws -> T {
        setAsRootWasCalled = true
        throw "Error"
    }
    
    override func show() throws -> T {
        showWasCalled = true
        throw "Error"
    }
    
    var onWasCalled = false
    var onProviderReceived: (() throws -> UIViewController)!
    override func on(_ provider: @escaping () throws -> UIViewController) -> Self {
        onWasCalled = true
        onProviderReceived = provider
        return self
    }
}

extension String: Error {}
class VirtualFactory: ViewFactoryType, ViewModelFactoryType {
    var buildViewReturn: Any!
    func buildView<T>() throws -> T where T : UIViewController {
        return try buildViewReturn as? T ?? "Error1".rethrow()
    }
    
    var buildViewArgReturn: Any!
    var buildViewArgReceived: Any!
    func buildView<T, ARG>(arg: ARG) throws -> T where T : UIViewController {
        buildViewArgReceived = arg
        return try buildViewArgReturn as? T ?? "Error2".rethrow()
    }
    
    var buildViewModelReturn: Any!
    func buildViewModel<T>() throws -> T {
        return try buildViewModelReturn as? T ?? "Error3".rethrow()
    }
    
    var buildViewModelArgReturn: Any!
    var buildViewModelArgReceived: Any!
    func buildViewModel<T, ARG>(arg: ARG) throws -> T {
        buildViewModelArgReceived = arg
        return try buildViewModelArgReturn as? T ?? "Error4".rethrow()
    }
    
    var buildViewModelArgArgReturn: Any!
    var buildViewModelArgArgReceived: (Any, Any)!
    func buildViewModel<T, ARG, ARG2>(arg: ARG, arg2: ARG2) throws -> T {
        buildViewModelArgArgReceived = (arg, arg2)
        return try buildViewModelArgArgReturn as? T ?? "Error5".rethrow()
    }
    
    var buildViewModelArgArgArgReturn: Any!
    var buildViewModelArgArgArgReceived: (Any, Any, Any)!
    func buildViewModel<T, ARG, ARG2, ARG3>(arg: ARG, arg2: ARG2, arg3: ARG3) throws -> T {
        buildViewModelArgArgArgReceived = (arg, arg2, arg3)
        return try buildViewModelArgArgArgReturn as? T ?? "Error6".rethrow()
    }
}
