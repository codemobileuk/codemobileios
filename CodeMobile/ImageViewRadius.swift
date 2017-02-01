//
//  ImageViewRadius.swift
//  CodeMobile
//
//  Created by Louis Woods on 01/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setRadius(radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.masksToBounds = true
    }
}
