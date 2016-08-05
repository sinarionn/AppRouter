//
//  AppRouterPresenterControllers.swift
//  AppRouter
//
//  Created by Antihevich on 8/2/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import Foundation
import UIKit

class AppRouterPresenterTabBarController: TabBarControllerWithExpectations { }
class AppRouterPresenterNavigationController: NavigationControllerWithExpectations {}
class AppRouterPresenterBaseController: ViewControllerWithExpectations {
    var initialized: Bool = false
}
class AppRouterPresenterAdditionalController: ViewControllerWithExpectations {
    var initialized: Bool = false
}