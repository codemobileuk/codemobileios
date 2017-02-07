//
//  DetailViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 03/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UISplitViewControllerDelegate {

    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    
    var fullname = ""
    var speakerImageURL: URL!
    var company = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullnameLbl.text = fullname
        speakerImageView.kf.setImage(with: speakerImageURL)
        companyLbl.text = company
        speakerImageView.setRadius(radius: speakerImageView.frame.size.height / 2)
        
 
    }
    
    
  
}
