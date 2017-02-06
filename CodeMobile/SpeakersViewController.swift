//
//  SpeakersViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 27/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData

class SpeakersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    private let coreData = CoreDataHandler()
    @IBOutlet weak var speakersTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.navigationItem.title = "Speakers"
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidLoad() {
        
        recieveCoreData()
    }
    
    private var sessions: [NSManagedObject] = []
    private var speakers: [NSManagedObject] = []
    
    func recieveCoreData() {
        
        speakers = coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
        sessions = coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
    }
     // MARK: Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return speakers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let speaker = speakers[indexPath.row]
        let cell = self.speakersTableView.dequeueReusableCell(withIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCell
        // Name
        let firstName = speaker.value(forKey: "firstname") as! String
        let lastName = speaker.value(forKey: "surname") as! String
        cell.speakerNameLbl.text = firstName + " " + lastName
        // Thumbnail
        cell.thumbnailImageView.setRadius(radius: cell.thumbnailImageView.frame.size.height / 2)
        let url = URL(string: speaker.value(forKey: "photoURL") as! String)
        cell.thumbnailImageView.kf.setImage(with: url)
        // Session titles
        for session in sessions {
            // Find speakerId in speaker array and collect relevent information to match session
            if session.value(forKey: "speakerId") as! Int == speaker.value(forKey: "speakerId") as! Int{
                
                    cell.sessionTitlesLbl.text = session.value(forKey: "SessionTitle") as! String?
            }
        }


        return cell
    }
    
}
// Class to represent UI of each speaker cell
class SpeakerCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var sessionTitlesLbl: UILabel!
}
