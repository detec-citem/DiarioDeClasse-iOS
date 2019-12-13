//
//  ViewController.swift
//  MinhaEscolaSP
//
//  Created by Victor Bozelli Alvarez on 12/02/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: Lifecycle
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.landscape, .portrait]
        }
        return .portrait
    }
}
