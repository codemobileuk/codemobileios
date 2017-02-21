//
//  DetailViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 03/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var fullname = ""
    var speakerImageURL: URL!
    var company = ""
    var profile : String!
    var talks : [String]!
    var socialMediaHidden = true
    var profileViewSelected = true
    var buildingName : String!
    var timeStarted : String!
    var talkName : String!

    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var linkedBtn: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var talksBtn: UIButton!
    @IBOutlet weak var viewC: UIView!
    @IBOutlet weak var viewA: UIView!
    @IBOutlet weak var viewB: UIButton!
    
    // MARK: - View Controller Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        buttonSelectedColour()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialData()
        setupTableViewUI()
    }
    
    // MARK: - Initialization
    
    private func setupInitialData() {
        
        fullNameLbl.text = fullname
        speakerImageView.kf.setImage(with: speakerImageURL)
        companyLbl.text = company
        speakerImageView.setRadius(radius: speakerImageView.frame.size.height / 2)
        //detailTextView.text = detail
        twitterBtn.isHidden = socialMediaHidden
        linkedBtn.isHidden = socialMediaHidden
        viewC.isHidden = socialMediaHidden
        viewA.isHidden = socialMediaHidden
        viewB.isHidden = socialMediaHidden
        detailTableView.isHidden = socialMediaHidden
        profileBtn.setTitleColor(Colours.codeMobileGrey, for: .normal)
        talksBtn.setTitleColor(Colours.codeMobileGrey, for: .normal)
        self.title = fullname
    }

    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if profileViewSelected == false {
            return talks.count
        }

        return 1
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if profileViewSelected == false {
            
            let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "TalkCell", for: indexPath) as! TalkCell
            cell.talkDesc.text = talks[indexPath.row]
            cell.buildingLbl.text = buildingName
            cell.talkNameLbl.text = talkName
            cell.timeOnLbl.text = timeStarted
            cell.buildingImageView.image = UIImage(named: buildingName)
            
            return cell
        } else {
            
            let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            cell.profileDesc.text = profile
            
            return cell
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func takeUserToTwitter(_ sender: Any) {
        
    }
    
    @IBAction func takeUserToLinkedIn(_ sender: Any) {
        
    }
    
    @IBAction func viewProfile(_ sender: Any) {
        
        profileBtn.setTitleColor(UIColor.red, for: .normal)
        talksBtn.setTitleColor(Colours.codeMobileGrey, for: .normal)
        profileViewSelected = true
        detailTableView.reloadData()
    }
    
    @IBAction func viewTalks(_ sender: Any) {
        
        profileBtn.setTitleColor(Colours.codeMobileGrey, for: .normal)
        talksBtn.setTitleColor(UIColor.red, for: .normal)
        profileViewSelected = false
        detailTableView.reloadData()
    }
    
    // MARK: - UI
    
    private func setupTableViewUI() {
        
        detailTableView.tableFooterView = UIView()
        detailTableView.estimatedRowHeight = 150
        detailTableView.rowHeight = UITableViewAutomaticDimension
        self.detailTableView.setNeedsLayout()
        self.detailTableView.layoutIfNeeded()
    }
    
    private func buttonSelectedColour() {
        
        if profileViewSelected == true {
            profileBtn.setTitleColor(UIColor.red, for: .normal)
            talksBtn.setTitleColor(Colours.codeMobileGrey, for: .normal)
        }else {
            profileBtn.setTitleColor(Colours.codeMobileGrey, for: .normal)
            talksBtn.setTitleColor(UIColor.red, for: .normal)
        }
    }
    
    
}

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var profileDesc: UILabel!
}

class TalkCell: UITableViewCell {
    
    @IBOutlet weak var talkNameLbl: UILabel!
    @IBOutlet weak var timeOnLbl: UILabel!
    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var buildingLbl: UILabel!
    @IBOutlet weak var talkDesc: UILabel!
}

