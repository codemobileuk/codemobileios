//
//  UIApplication.swift
//  CodeMobile
//
//  Created by Louis Woods on 22/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

