//
//  ScheduleViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 19/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
import SWRevealViewController

class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate {
    
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var openBtn: UIBarButtonItem!
    @IBOutlet weak var sessionSegment: UISegmentedControl!
    @IBOutlet weak var scheduleSpinner: UIActivityIndicatorView!
    
    private let api = ApiHandler()
    private let coreData = CoreDataHandler()
    var userIsFiltering = false
    var filterItems = [Int]()
    
    // MARK: - View Controller Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        scheduleTableView.reloadData()
        setupAndRecieveCoreData()
        
        switch (TagsStruct.date){
            
        case "2017-04-18" :  sessionSegment.selectedSegmentIndex = 0
        case "2017-04-19" :  sessionSegment.selectedSegmentIndex = 1
        case "2017-04-20" :  sessionSegment.selectedSegmentIndex = 2
        default: sessionSegment.selectedSegmentIndex = 0
            
        }

    }
    
    override func viewDidLoad() {
    
        setupSplitView()
        setupSideMenu()
        setupUI()
        scheduleTableView.tableFooterView = UIView()
        TagsStruct.date = "2017-04-18"
        scheduleSpinner.hidesWhenStopped = true
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if sortedSections.isEmpty{ return 0 }
        return timeSections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let tableSection = timeSections[sortedSections[section]]
        let tableItem = tableSection![0]
        let title = UILabel()
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = UIFont.boldSystemFont(ofSize: 16)
        // If item is break
        if tableItem.title == "Break" {
            title.textColor = UIColor.white
            header.textLabel!.textColor=title.textColor
            header.contentView.backgroundColor = Colours.codeMobileGrey
        } else {
            title.textColor = UIColor.black
            header.textLabel!.textColor=title.textColor
            header.contentView.backgroundColor = UIColor.groupTableViewBackground
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sortedSections.isEmpty{ return 0 }
        var day = ""
        for item in timeSections[sortedSections[section]]! { day = item.day }
        // If date of section is not current date selected for sorting, return 0 number of rows
        if day != TagsStruct.date { return 0 }
        // If item is break
        let tableSection = timeSections[sortedSections[section]]
        let tableItem = tableSection![0]
        if tableItem.title == "Break" { return 0 }

        print(timeSections[sortedSections[section]]!.count)
        return timeSections[sortedSections[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if sortedSections.isEmpty{ return "" }
        var day = ""
        for item in timeSections[sortedSections[section]]! { day = item.day }
        // If date of section is not current date selected for sorting, return nil so no header appears
        if day != TagsStruct.date { return nil }
        // Seperate only the time from the day/time string & remove the seconds from the time
        let returnvalue = sortedSections[section].components(separatedBy: "T").last
        let endIndex = returnvalue?.index((returnvalue?.endIndex)!, offsetBy:  -3)
        let returnvalue2 = endDateSections[section].components(separatedBy: "T").last
        // If item is break
        let tableSection = timeSections[sortedSections[section]]
        let tableItem = tableSection![0]
        if tableItem.title == "Break" {
             return (returnvalue?.substring(to: endIndex!))! + " - " + (returnvalue2?.substring(to: endIndex!))! + "  Break"
        }
        
        return (returnvalue?.substring(to: endIndex!))! + " - " + (returnvalue2?.substring(to: endIndex!))!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.scheduleTableView.dequeueReusableCell(withIdentifier: "FullCell", for: indexPath) as! FullWidthCell
        let tableSection = timeSections[sortedSections[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        cell.sessionTitleLbl.text = tableItem.title
        cell.buildingIconImgView.image = UIImage(named: tableItem.locationName)
        cell.sessionTitleLbl.textColor = Colours.codeMobileGrey
        for speaker in speakers {
            // Find speakerId in speaker array and collect relevent information to match session
            if speaker.value(forKey: "speakerId") as! Int == tableItem.speakerId {
                
                let firstName = speaker.value(forKey: "firstname") as! String
                let lastName = speaker.value(forKey: "surname") as! String
                cell.sessionFullNameLbl.text = firstName + " " + lastName
             
                var allTags = [String]()
                let sessionId = sessionTags[tableItem.sessionId]
                for tag in sessionId! {
                    allTags.append(tag.title)
                }
                cell.tagsArray = allTags
                cell.tagsCollectionView.reloadData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            let index = self.scheduleTableView.indexPathForSelectedRow! as NSIndexPath
            
            let nav = segue.destination as! UINavigationController
            
            let vc = nav.viewControllers[0] as! DetailViewController
            
            let tableSection = timeSections[sortedSections[index.section]]
            let tableItem = tableSection![index.row]
            
            vc.extendedLayoutIncludesOpaqueBars = true
            for speaker in speakers {
                // Find speakerId in speaker array and collect relevent information to match session
                if speaker.value(forKey: "speakerId") as! Int == tableItem.speakerId {
                    
                    let firstName = speaker.value(forKey: "firstname") as! String
                    let lastName = speaker.value(forKey: "surname") as! String
                    vc.fullname = firstName + " " + lastName
                    let url = URL(string: speaker.value(forKey: "photoURL") as! String)
                    vc.speakerImageURL = url
                    vc.company = speaker.value(forKey: "organisation") as! String
                    vc.profile = speaker.value(forKey: "profile") as! String
                    
                }
            }
            
            var descArray = [String]()
            descArray.append(tableItem.description)
            vc.buildingName = tableItem.locationName
            vc.talkName = tableItem.title
           
            
            vc.talks = descArray
            vc.profileViewSelected = false
            vc.socialMediaHidden = false
            
            let startTime = Date().formatDate(dateToFormat: tableItem.untouchedDate)
            vc.timeStarted = Date().wordedDate(Date: startTime)
            
            self.scheduleTableView.deselectRow(at: index as IndexPath, animated: true)
        }
    }
    
    // MARK: - SplitView
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    
    private func setupSplitView(){
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    }
    
    // MARK: - Core Data
    
    private var sessions: [NSManagedObject] = []
    private var speakers: [NSManagedObject] = []
    private var tags: [NSManagedObject] = []
    
    private func setupAndRecieveCoreData() {
        
        speakers = coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
        sessions = coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
        // TAGS
        tags = coreData.recieveCoreData(entityNamed: Entities.TAGS)
        scheduleSpinner.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if tags.isEmpty{
            print("Tags core data is empty, storing tags data...")
            api.storeTags(updateData: { () -> Void in
                self.tags = self.coreData.recieveCoreData(entityNamed: Entities.TAGS)
                self.scheduleSpinner.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.sortOutSections()
                self.sortOutTags()
            })
        } else {
            print("Tags core data is not empty")
            scheduleSpinner.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            sortOutSections()
            sortOutTags()
        }

       
    }
    
    private var timeSections = [String: [TableItem]]()
    private var sortedSections = [String]()
    private var endDateSections = [String]()
    
    // Function responsible for sorting out schedule data into seperate sections
    private func sortOutSections() {
        
        timeSections.removeAll()
        sortedSections.removeAll()
        endDateSections.removeAll()
        // THIS IS A CONFUSING FUNCTION NOW
        
        if TagsStruct.tagsArray.isEmpty {
            TagsStruct.userIsFiltering = false
        }
        
        print(sessionTags)
        var completedTitles = [String]()
        completedTitles.removeAll()
        
        for item in sessions {
            
            if TagsStruct.userIsFiltering == true {
            
                var sessionId = Int()
                sessionId = item.value(forKey: "SessionId") as! Int!
                let tags = sessionTags[sessionId]
                
                if tags != nil {
                for tag in tags! {
                    
                    if TagsStruct.tagsArray.contains(tag.tagId){
                        
                        var title = String()
                        var date = String()
                        var endDate = String()
                        var speaker = Int()
                        var building = String()
                        var description = String()
                        var untouchedDate = String()
                        
                        untouchedDate = (item.value(forKey: "SessionStartDateTime") as! String?)!
                        description = (item.value(forKey: "sessionDescription") as! String?)!
                        sessionId = item.value(forKey: "SessionId") as! Int!
                        date = (item.value(forKey: "SessionStartDateTime") as! String?)!
                        endDate = (item.value(forKey: "SessionEndDateTime") as! String?)!
                        
                        // Format date to remove useless data in string
                        let dated = Date().formatDate(dateToFormat: (item.value(forKey: "SessionStartDateTime") as! String?)!)
                        
                        title = (item.value(forKey: "SessionTitle") as! String?)!
                        speaker = (item.value(forKey: "speakerId") as! Int )
                        building = (item.value(forKey: "sessionLocationName") as! String)
                        
                        // Get day of item without time
                        let day = date.components(separatedBy: "T").first
                        
                        // If array doesnt contain day/time of session add new key, else add TableItem to array to key already in array
                        if self.timeSections.index(forKey: date) == nil {
                            self.timeSections[date] = [TableItem(title: title, date: dated, speakerId: speaker, day: day!, locationName: building, sessionId: sessionId, description: description, untouchedDate: untouchedDate)]
                            completedTitles.append(title)
                        } else {
                            if completedTitles.contains(title) == false{
                               self.timeSections[date]!.append(TableItem(title: title, date: dated, speakerId: speaker, day: day!, locationName: building,  sessionId: sessionId, description: description, untouchedDate: untouchedDate))
                               completedTitles.append(title)
                            }
                           
                        }
                        
                        if self.endDateSections.contains(endDate) == false {
                            endDateSections.append(endDate)
                        }
                        
                    }

                }
                }
                
            }
            else {
                
                var title = String()
                var date = String()
                var endDate = String()
                var speaker = Int()
                var building = String()
                var sessionId = Int()
                var description = String()
                var untouchedDate = String()
                
                untouchedDate = (item.value(forKey: "SessionStartDateTime") as! String?)!
                description = (item.value(forKey: "sessionDescription") as! String?)!
                sessionId = item.value(forKey: "SessionId") as! Int!
                date = (item.value(forKey: "SessionStartDateTime") as! String?)!
                endDate = (item.value(forKey: "SessionEndDateTime") as! String?)!
                
                // Format date to remove useless data in string
                let dated = Date().formatDate(dateToFormat: (item.value(forKey: "SessionStartDateTime") as! String?)!)
                
                title = (item.value(forKey: "SessionTitle") as! String?)!
             
                speaker = (item.value(forKey: "speakerId") as! Int )
                building = (item.value(forKey: "sessionLocationName") as! String)
                
                // Get day of item without time
                let day = date.components(separatedBy: "T").first
                
                // If array doesnt contain day/time of session add new key, else add TableItem to array to key already in array
                if self.timeSections.index(forKey: date) == nil {
                    self.timeSections[date] = [TableItem(title: title, date: dated, speakerId: speaker, day: day!, locationName: building, sessionId: sessionId, description: description, untouchedDate: untouchedDate)]
                } else {
                    self.timeSections[date]!.append(TableItem(title: title, date: dated, speakerId: speaker, day: day!, locationName: building,  sessionId: sessionId, description: description, untouchedDate: untouchedDate))
                }
                
                if self.endDateSections.contains(endDate) == false {
                    endDateSections.append(endDate)
                }

                
            }
            
            
        }
      
        for item in timeSections { sortedSections.append(item.key) }
       
        // Sort array in time order
        sortedSections = sortedSections.sorted {$0 < $1}
        // Update table
        scheduleTableView.reloadData()
    }
    
    private var sessionTags = [Int: [SessionTags]]()
   
    private func sortOutTags() {
        
        sessionTags.removeAll()
        
        for item in tags {
            
            var title: String
            var tagId : Int
            var sessionId : Int
            
            title = (item.value(forKey: "tag") as! String?)!
            tagId = (item.value(forKey: "tagId") as! Int )
            sessionId = (item.value(forKey: "sessionId") as! Int )
            
            if self.sessionTags.index(forKey: sessionId) == nil {
                self.sessionTags[sessionId] = [SessionTags(title: title, tagId: tagId)] // tagId unused?
            } else {
                self.sessionTags[sessionId]!.append(SessionTags(title: title, tagId: tagId))
            }
        }
    }

    // MARK: - Other
    
    private func setupSideMenu() {
        
        openBtn.target = self.revealViewController()
        openBtn.action = #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    private var chosenDate = "2017-04-18"
    
    private func setupUI() {
        
        sessionSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
        sessionSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
    }
    
    @IBAction func filterSessions(_ sender: Any) {
        
        switch sessionSegment.selectedSegmentIndex{
        case 0 :
            TagsStruct.date = "2017-04-18"
            scheduleTableView.reloadData()
            //userIsFiltering = false
            //filterItems.removeAll()
            //sortOutSections()
        case 1 :
            //userIsFiltering = true
            TagsStruct.date = "2017-04-19"
             scheduleTableView.reloadData()
            //filterItems.removeAll()
            //filterItems.append(2)
            //sortOutSections()
        default :
            //userIsFiltering = true
            TagsStruct.date = "2017-04-20"
             scheduleTableView.reloadData()
            //filterItems.removeAll()
            //filterItems.append(1)
            //sortOutSections()
        }
    }
}

// MARK: - Session TableView Cell UI
class FullWidthCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var sessionFullNameLbl: UILabel!
    @IBOutlet weak var buildingIconImgView: UIImageView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    var tagsArray = [String]()

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = tagsArray[indexPath.row]
        let cell = tagsCollectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCollectionViewCell
        cell.tagLbl.text = item
        //cell.tagLbl.textColor = UIColor.white
        cell.setRadius(radius: 2.5)
        //cell.backgroundColor = Colours.codeMobileGrey
        cell.backgroundColor = UIColor.groupTableViewBackground
        

        return cell
    }
}

class TagCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var tagLbl: UILabel!
}
// MARK: - Session Model
struct TableItem {
    
    let title: String
    let date : Date
    let speakerId : Int
    let day : String
    let locationName : String
    let sessionId : Int
    let description : String
    let untouchedDate : String
}

// MARK: - Tags Model
struct SessionTags {
    
    let title: String
    let tagId : Int
}
