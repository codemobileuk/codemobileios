//
//  DetailViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 03/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var fullname = ""
    var speakerImageURL: URL!
    var company = ""
    var profile : String!
    var talks : [String]!
    var viewIsHidden = true
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
        viewVisibility()
       // self.navigationController?.isNavigationBarHidden = false

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialData()
        setupTableViewUI()
        setupUI()
         self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Initialization
    
    private func setupInitialData() {
        
        fullNameLbl.text = fullname
        speakerImageView.kf.setImage(with: speakerImageURL)
        companyLbl.text = company
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
        
        print("Twitter button pressed")
    }
    
    @IBAction func takeUserToLinkedIn(_ sender: Any) {
        
        print("Linked in button pressed")
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
    
    private func setupUI() {
        
        speakerImageView.setRadius(radius: speakerImageView.frame.size.height / 2)
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
    
    private func viewVisibility() {
        
        viewC.isHidden = viewIsHidden
        viewA.isHidden = viewIsHidden
        viewB.isHidden = viewIsHidden
        detailTableView.isHidden = viewIsHidden
        twitterBtn.isHidden = viewIsHidden
        linkedBtn.isHidden = viewIsHidden
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

