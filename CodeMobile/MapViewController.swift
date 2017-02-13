//
//  MapViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 27/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var locationTableView: UITableView!
    
    // MARK: View Controller Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        
        setupSplitView()
    }
    
    // MARK: Table View Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.locationTableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let url = URL(string: "http://www.atop-ltd.co.uk/images/chester2.jpg")
        cell.locationThumbnailImageView.kf.setImage(with: url)
        cell.locationThumbnailImageView.setRadius(radius: 5)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Header"
    }
    
    // MARK: Split View
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func setupSplitView(){
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    }

    
}
// MARK: Location TableView Cell UI
class LocationCell : UITableViewCell {
    
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var milesLbl: UILabel!
    @IBOutlet weak var locationThumbnailImageView: UIImageView!

}

// MARK: Location Model
struct Locations {
    
    var sectionName : String!
    var locationNames : [String]!
    var miles : [String]!
    var imagesURLs : [String]!
}


