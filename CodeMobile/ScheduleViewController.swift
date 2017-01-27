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
    @IBOutlet weak var currentDateSelected: UILabel!
    
    let api = ApiHandler()
    let coreData = CoreDataHandler()
    
    var sessions: [NSManagedObject] = []
    var speakers: [NSManagedObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.navigationItem.title = "Schedule"
        checkCoreDataIsEmpty()
        
        let rightBtn = UIBarButtonItem(title: "Sort", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sortByDate(sender:)))
        tabBarController?.navigationItem.rightBarButtonItem = rightBtn
        
        
    }
    
    var chosenDate = "2017-04-18"
    func sortByDate(sender: UIBarButtonItem) {
        
        let optionMenu = UIAlertController(title: nil, message: "Sort by date", preferredStyle: .actionSheet)
        
        let dayOne = UIAlertAction(title: "Tuesday 18th April", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Day 1 tapped")
            self.chosenDate = "2017-04-18"
            self.currentDateSelected.text = "Tuesday 18th April"
            self.scheduleTableView.reloadData()
            
        })
        let dayTwo = UIAlertAction(title: "Wednesday 19th April", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Day 2 tapped")
            self.chosenDate = "2017-04-19"
            self.currentDateSelected.text = "Wednesday 19th April"
            self.scheduleTableView.reloadData()
            
        })
        let dayThree = UIAlertAction(title: "Thursday 20th April", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Day 3 tapped")
            self.chosenDate = "2017-04-20"
            self.currentDateSelected.text = "Thursday 20th April"
            self.scheduleTableView.reloadData()
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(dayOne)
        optionMenu.addAction(dayTwo)
        optionMenu.addAction(dayThree)
        optionMenu.addAction(cancel)
        optionMenu.view.tintColor = UIColor.red
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    @IBAction func deleteTest(_ sender: Any) {
        
        coreData.deleteAllData(entityNamed: Entities.SCHEDULE)
        coreData.deleteAllData(entityNamed: Entities.SPEAKERS)
        sessions.removeAll()
        speakers.removeAll()
        daysSections.removeAll()
        sortedSections.removeAll()
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
                self.sortOutSections()
                print(self.sessions )
                self.scheduleTableView.reloadData()
            })
        } else {
            print("Schedule core data is not empty")
            if sortedSections.isEmpty{
                self.sortOutSections()
            }
        }
    }
    
    var timeSections = [String: [TableItem]]()
    var sortedSections = [String]()
    var daysSections = [String: [String:[TableItem]]]()
    
    func sortOutSections() {
        
        for item in sessions {
            
            var title = String()
            var date = String()
            var speaker = Int()
            
            date = (item.value(forKey: "SessionStartDateTime") as! String?)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dated = dateFormatter.date(from: date)
            
            
            title = (item.value(forKey: "SessionTitle") as! String?)!
            
            speaker = (item.value(forKey: "speakerId") as! Int )
            
            let day = date.components(separatedBy: "T").first
            
            if self.timeSections.index(forKey: date) == nil {
                self.timeSections[date] = [TableItem(title: title, date: dated!, speakerId: speaker, day: day!)]
            } else {
                self.timeSections[date]!.append(TableItem(title: title, date: dated!, speakerId: speaker, day: day!))
            }
            
        }
        for item in timeSections {
            
            sortedSections.append(item.key)
        }
        
        sortedSections = sortedSections.sorted {$0 < $1}
        //print(sortedSections)
        print(daysSections.keys)
        scheduleTableView.reloadData()
        
    }
    
    
    // MARK: Table View Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if sortedSections.isEmpty{
            return 0
        }
        return timeSections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    var timesArray = [String]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedSections.isEmpty{
            return 0
        }
        var day = ""
        for item in timeSections[sortedSections[section]]! {
            
            day = item.day
        }
        
        if day != chosenDate {
            
            return 0
        }
        
        return timeSections[sortedSections[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if sortedSections.isEmpty{
            return ""
        }
        
        var day = ""
        for item in timeSections[sortedSections[section]]! {
            
            day = item.day
        }
        
        if day != chosenDate {
            
            return nil
        }
        
        let returnvalue = sortedSections[section].components(separatedBy: "T").last
        let endIndex = returnvalue?.index((returnvalue?.endIndex)!, offsetBy:  -3)
        
        return returnvalue?.substring(to: endIndex!)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.scheduleTableView.dequeueReusableCell(withIdentifier: "FullCell", for: indexPath) as! FullWidthCell
        
        let tableSection = timeSections[sortedSections[indexPath.section]]
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
    let day : String
}







