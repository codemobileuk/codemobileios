//
//  UILabel.swift
//  CodeMobile
//
//  Created by Louis Woods on 04/04/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

extension UILabel {

    func lines(yourLabel: UILabel){
        var lineCount = 0;
        let textSize = CGSize(width: yourLabel.frame.size.width, height: CGFloat(Float.infinity));
        let rHeight = lroundf(Float(yourLabel.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(yourLabel.font.lineHeight));
        lineCount = rHeight/charSize
        print("No of lines \(lineCount)")
        
        
    }



}
