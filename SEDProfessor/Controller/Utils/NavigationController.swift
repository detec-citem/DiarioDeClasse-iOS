//
//  NavigationController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 26/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

final class NavigationController: UINavigationController {
    //MARK: Methods
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let viewController = visibleViewController, !(viewController is UIAlertController) {
            return viewController.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }
    
    override var shouldAutorotate: Bool {
        if let viewController = visibleViewController, !(viewController is UIAlertController) {
            return viewController.shouldAutorotate
        }
        return super.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let viewController = visibleViewController, !(viewController is UIAlertController) {
            return viewController.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
}
