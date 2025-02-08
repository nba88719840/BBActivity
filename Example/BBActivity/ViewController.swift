//
//  ViewController.swift
//  BBActivity
//
//  Created by nba88719840 on 02/08/2025.
//  Copyright (c) 2025 nba88719840. All rights reserved.
//

import UIKit
import BBActivity
import SnapKit
import ActiveLabel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let manager = ActivityManager.shared
        print("\(manager.isLogin)")
        let btn: UIButton = UIButton(type: .custom)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

