//
//  DetailViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 03/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    
    var fullname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullnameLbl.text = fullname
    }

  
}
