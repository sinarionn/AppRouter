//
//  ViewControllerWithExpectations.swift
//  CodeSnippets
//
//  Created by Artem Antihevich on 6/23/16.
//  Copyright © 2016 Artem Antihevich. All rights reserved.
//

import UIKit
import XCTest

class TabBarControllerWithExpectations: UITabBarController {
    var viewDidLoadExpectation: XCTestExpectation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadExpectation?.fulfill()
    }
}
