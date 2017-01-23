//
//  HomeViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 19/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//
//
import UIKit
import CoreData

class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    let api = ApiHandler()
    let coreData = CoreDataHandler()
    
    var sessions: [NSManagedObject] = []
    var speakers: [NSManagedObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.navigationItem.title = "Schedule"
        checkCoreDataIsEmpty()
       
    }
 
    @IBAction func testAction(_ sender: Any) {
        
    }
    
    @IBAction func deleteTest(_ sender: Any) {
        
        coreData.deleteAllData(entityNamed: Entities.SCHEDULE)
        coreData.deleteAllData(entityNamed: Entities.SPEAKERS)
        sessions.removeAll()
        speakers.removeAll()
        scheduleTableView.reloadData()
        
    }
    
    func checkCoreDataIsEmpty() {
        
        // Check Speaker Core Data
        speakers = coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
        
        if speakers.isEmpty{
            print("Speakers core data is empty, storing speakers data...")
            api.storeSpeakers(updateData: { () -> Void in
                 self.speakers = self.coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
                self.scheduleTableView.reloadData()
            })
        } else {print("Speakers core data is not empty")}
        
        // Check Schedule Core Data
        sessions = coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
       
        if sessions.isEmpty{
            print("Schedule core data is empty, storing schedule data...")
            api.storeSchedule(updateData: { () -> Void in
                self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
                self.scheduleTableView.reloadData()
            })
        } else {print("Schedule core data is not empty")}


        
    }
    // Table View Functions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sessions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = sessions[indexPath.row]
        let cell = self.scheduleTableView.dequeueReusableCell(withIdentifier: "FullCell", for: indexPath) as! FullWidthCell
        cell.sessionTitleLbl.text = item.value(forKey: "SessionTitle") as! String?
        for speaker in speakers {
         
            if speaker.value(forKey: "speakerId") as! Int == item.value(forKey: "speakerId") as! Int {
                let firstName = speaker.value(forKey: "firstname") as! String
                let lastName = speaker.value(forKey: "surname") as! String
                cell.sessionFullNameLbl.text = firstName + " " + lastName

            }
        }
        
        return cell
    }
    
}

class FullWidthCell: UITableViewCell {
    
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var sessionFullNameLbl: UILabel!
    @IBOutlet weak var buildingIconImgView: UIImageView!
    
   
}


