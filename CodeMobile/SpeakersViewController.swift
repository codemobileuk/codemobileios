//
//  SpeakersViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 27/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class SpeakersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var speakersTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.navigationItem.title = "Speakers"
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
     // MARK: Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.speakersTableView.dequeueReusableCell(withIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCell
        cell.thumbnailImageView.setRadius(radius: cell.thumbnailImageView.frame.size.height / 2)
        return cell
    }
    
}
// Class to represent UI of each speaker cell
class SpeakerCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var sessionTitlesLbl: UILabel!
}
