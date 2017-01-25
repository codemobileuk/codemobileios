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
        
        if sections.isEmpty {
        retriever()
        }
        
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
                self.retriever()
                print(self.sessions )
                self.scheduleTableView.reloadData()
            })
        } else {print("Schedule core data is not empty")}
    }
    
    func retriever() {
        
        
        print(sessions)
        
        for item in sessions {
            
            var title = String()
            var date = String()
            var speaker = Int()
            
            date = (item.value(forKey: "SessionStartDateTime") as! String?)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
            let dated = dateFormatter.date(from: date)
            
            
            title = (item.value(forKey: "SessionTitle") as! String?)!
            
            speaker = (item.value(forKey: "speakerId") as! Int )
            if self.sections.index(forKey: date) == nil {
                self.sections[date] = [TableItem(title: title, date: dated!, speakerId: speaker)]
            } else {
                self.sections[date]!.append(TableItem(title: title, date: dated!, speakerId: speaker))
            }

        }
        for item in sections {
            
            sortedSections.append(item.key)
        }
      
        sortedSections = sortedSections.sorted {$0 < $1}
        scheduleTableView.reloadData()
        
    }
    // Table View Functions
    

    var sections = [String: [TableItem]]()
    var sortedSections = [String]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if sortedSections.isEmpty{
            return 0
        }
        return sections.count
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    var timesArray = [String]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedSections.isEmpty{
            return 0
        }
        return sections[sortedSections[section]]!.count
    }
 
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if sortedSections.isEmpty{
            return ""
        }

        return sortedSections[section]//item.value(forKey: "SessionStartDateTime") as! String?
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.scheduleTableView.dequeueReusableCell(withIdentifier: "FullCell", for: indexPath) as! FullWidthCell
        
        let tableSection = sections[sortedSections[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        
        cell.sessionTitleLbl.text = tableItem.title
        for speaker in speakers {
         
            if speaker.value(forKey: "speakerId") as! Int == tableItem.speakerId {
                
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

struct TableItem {
    let title: String
    let date : Date
    let speakerId : Int
}





