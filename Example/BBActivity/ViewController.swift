//
//  ViewController.swift
//  BBActivity
//
//  Created by nba88719840 on 02/08/2025.
//  Copyright (c) 2025 nba88719840. All rights reserved.
//

import UIKit
import BBActivity

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let manager = ActivityManager.shared
        print("\(manager.isLogin)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

