//
//  ScheduleViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 19/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData

class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var currentDateSelected: UILabel!
    
    private let api = ApiHandler()
    private let coreData = CoreDataHandler()
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Navigation bar setup
        tabBarController?.navigationItem.title = "Schedule"
        let rightBtn = UIBarButtonItem(title: "Sort", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sortByDate(sender:)))
        tabBarController?.navigationItem.rightBarButtonItem = rightBtn
        
        setupScheduleData()
    }
    
    private var chosenDate = "2017-04-18"
    
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
    
    // Test function - This function will be deleted/ Used to delete all data instead of having to re-run the app
    @IBAction func deleteTest(_ sender: Any) {
        
        coreData.deleteAllData(entityNamed: Entities.SCHEDULE)
        coreData.deleteAllData(entityNamed: Entities.SPEAKERS)
        sessions.removeAll()
        speakers.removeAll()
        sortedSections.removeAll()
        timeSections.removeAll()
        scheduleTableView.reloadData()
    }
    
    private var sessions: [NSManagedObject] = []
    private var speakers: [NSManagedObject] = []
    
    private func setupScheduleData() {
        
        // Speaker Core Data
        // Recieve speaker data from core data
        speakers = coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
        // Check if data contains data, if not retrieve data from the API then store the data into speaker array.
        if speakers.isEmpty{
            print("Speakers core data is empty, storing speakers data...")
            api.storeSpeakers(updateData: { () -> Void in
                self.speakers = self.coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
                self.scheduleTableView.reloadData()
            })
        } else {print("Speakers core data is not empty")}
        
        // Sessions Core Data - Repeated for session information
        sessions = coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
        
        if sessions.isEmpty{
            print("Schedule core data is empty, storing schedule data...")
            api.storeSchedule(updateData: { () -> Void in
                self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
                self.sortOutSections()
                self.scheduleTableView.reloadData()
            })
        } else {
            print("Schedule core data is not empty")
            if sortedSections.isEmpty{
                // Split data into correct sections for table view
                self.sortOutSections()
            }
        }
    }
    
    private var timeSections = [String: [TableItem]]()
    private var sortedSections = [String]()
    private var endDateSections = [String]()
    
    private func sortOutSections() {
        
        for item in sessions {
            
            var title = String()
            var date = String()
            var endDate = String()
            var speaker = Int()
            var building = String()
            
            date = (item.value(forKey: "SessionStartDateTime") as! String?)!
            endDate = (item.value(forKey: "SessionEndDateTime") as! String?)!

            // Format date to remove useless data in string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dated = dateFormatter.date(from: date)
            
            title = (item.value(forKey: "SessionTitle") as! String?)!
            speaker = (item.value(forKey: "speakerId") as! Int )
            building = (item.value(forKey: "sessionLocationName") as! String)
            
            // Get day of item without time
            let day = date.components(separatedBy: "T").first
            
            // If array doesnt contain day/time of session add new key, else add TableItem to array to key already in array
            if self.timeSections.index(forKey: date) == nil {
                self.timeSections[date] = [TableItem(title: title, date: dated!, speakerId: speaker, day: day!, locationName: building)]
            } else {
                self.timeSections[date]!.append(TableItem(title: title, date: dated!, speakerId: speaker, day: day!, locationName: building))
            }
            
            if self.endDateSections.contains(endDate) == false {
                endDateSections.append(endDate)
            }
            
           
        }
        for item in timeSections { sortedSections.append(item.key) }
        // Sort array in time order
        sortedSections = sortedSections.sorted {$0 < $1}
        // Update table
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sortedSections.isEmpty{ return 0 }
        var day = ""
        for item in timeSections[sortedSections[section]]! { day = item.day }
        // If date of section is not current date selected for sorting, return 0 number of rows
        if day != chosenDate { return 0 }
        
        return timeSections[sortedSections[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if sortedSections.isEmpty{ return "" }
        var day = ""
        for item in timeSections[sortedSections[section]]! { day = item.day }
        // If date of section is not current date selected for sorting, return nil so no header appears
        if day != chosenDate { return nil }
        // Seperate only the time from the day/time string & remove the seconds from the time
        let returnvalue = sortedSections[section].components(separatedBy: "T").last
        let endIndex = returnvalue?.index((returnvalue?.endIndex)!, offsetBy:  -3)
        
        let returnvalue2 = endDateSections[section].components(separatedBy: "T").last
        
        
        return (returnvalue?.substring(to: endIndex!))! + " - " + (returnvalue2?.substring(to: endIndex!))!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.scheduleTableView.dequeueReusableCell(withIdentifier: "FullCell", for: indexPath) as! FullWidthCell
        let tableSection = timeSections[sortedSections[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        cell.sessionTitleLbl.text = tableItem.title
        cell.buildingIconImgView.image = UIImage(named: tableItem.locationName)
        for speaker in speakers {
            // Find speakerId in speaker array and collect relevent information to match session
            if speaker.value(forKey: "speakerId") as! Int == tableItem.speakerId {
        
                let firstName = speaker.value(forKey: "firstname") as! String
                let lastName = speaker.value(forKey: "surname") as! String
                cell.sessionFullNameLbl.text = firstName + " " + lastName
            }
        }
        return cell
    }
}

// Class to represent UI of each cell
class FullWidthCell: UITableViewCell {
    
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var sessionFullNameLbl: UILabel!
    @IBOutlet weak var buildingIconImgView: UIImageView!
}

// Struct to represent data in each table cell
struct TableItem {
    
    let title: String
    let date : Date
    let speakerId : Int
    let day : String
    let locationName : String
}







