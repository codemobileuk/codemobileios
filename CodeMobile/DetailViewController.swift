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
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var linkedBtn: UIButton!
    
    var fullname = ""
    var speakerImageURL: URL!
    var company = ""
    var detail : String!
    var socialMediaHidden = true
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDetailData()
    }
    
    // MARK: - Other
    
    func setupDetailData() {
        
        fullnameLbl.text = fullname
        speakerImageView.kf.setImage(with: speakerImageURL)
        companyLbl.text = company
        speakerImageView.setRadius(radius: speakerImageView.frame.size.height / 2)
        detailTextView.text = detail
        twitterBtn.isHidden = socialMediaHidden
        linkedBtn.isHidden = socialMediaHidden
    }
    
    @IBAction func takeUserToTwitter(_ sender: Any) {
    }
    
    @IBAction func takeUserToLinkedIn(_ sender: Any) {
    }
    
}
