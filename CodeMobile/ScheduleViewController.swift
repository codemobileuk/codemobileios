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
    
    // MARK: - Properties
    var userIsFiltering = false
    var filterItems = [Int]()
    
    private var favouriteSessionIds = [Int]()
    private let api = ApiHandler()
    private let coreData = CoreDataHandler()
    private var sessions: [NSManagedObject] = []
    private var speakers: [NSManagedObject] = []
    private var tags: [NSManagedObject] = []
    private var chosenDate = "2017-04-18"
    private var timeSections = [String: [TableItem]]()
    private var sortedSections = [String]()
    private var sessionTags = [Int: [SessionTags]]()
    
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var openBtn: UIBarButtonItem!
    @IBOutlet weak var sessionSegment: UISegmentedControl!
    @IBOutlet weak var scheduleSpinner: UIActivityIndicatorView!
    
    // MARK: - View Controller Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        
        scheduleTableView.reloadData()
        checkDateAndSetSegment()
        favouriteSessionIds = UserDefaults.standard.array(forKey: "Favourites")  as? [Int] ?? [Int]()
    }
    
    override func viewDidLoad() {
        
        setupAndRecieveCoreData()
        setupSplitView()
        setupSideMenu()
        setupUI()
        TagsStruct.date = "2017-04-18"
        // Define identifier
        _ = Notification.Name("NotificationIdentifier")
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name(rawValue: "UpdateTags"), object: nil)
    }
    
    // MARK: - Notifications
    func methodOfReceivedNotification(notification: NSNotification){
        
        switch(notification.name.rawValue){
            
        case "UpdateTags":
         setupAndRecieveCoreData()
         scheduleTableView.reloadData()
         checkDateAndSetSegment()
        default:
           break
        }
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
        // If item is break - No longer needed throughout app, as API has fixed this?
        if tableItem.title == "Break" || tableItem.title == "Lunch" || tableItem.title == "Tea / Coffee / Registration" {
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
        if tableItem.title == "Break" || tableItem.title == "Lunch" || tableItem.title == "Tea / Coffee / Registration"{ return 0 }
        
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
       
        // If item is break
        let tableSection = timeSections[sortedSections[section]]
        let tableItem = tableSection![0]
        let returnvalue2 = tableItem.endDate.components(separatedBy: "T").last
        
        if tableItem.title == "Break" || tableItem.title == "Lunch" || tableItem.title == "Tea / Coffee / Registration"{
            return (returnvalue?.substring(to: endIndex!))! + " - " + (returnvalue2?.substring(to: endIndex!))! + "  " + tableItem.title
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
                if sessionId != nil {
                    for tag in sessionId! {
                        allTags.append(tag.title)
                    }
                }
                cell.tagsArray = allTags
                cell.tagsCollectionView.reloadData()
                
                if favouriteSessionIds.contains(tableItem.sessionId){
                    cell.favouriteButton.setImage(UIImage(named: "star (1)"), for: UIControlState.normal)
                } else {
                    cell.favouriteButton.setImage(UIImage(named: "star"), for: UIControlState.normal)
                }
                cell.favouriteButton.addTarget(self, action: #selector(ScheduleViewController.addFavourite(sender:)), for: UIControlEvents.touchUpInside)
                cell.favouriteButton.tag = tableItem.sessionId
            }
        }
        return cell
    }
    
    func addFavourite(sender:UIButton!) {
    
        print("Favourite button pressed, the session id is: \(sender.tag)")
        let sessionId = sender.tag
        print(favouriteSessionIds)
        
        if favouriteSessionIds.contains(sessionId){
        
            sender.setImage(UIImage(named: "star"), for: UIControlState.normal)
            if let index = favouriteSessionIds.index(of: sessionId) {
                favouriteSessionIds.remove(at: index)
            }
        } else {
        
            sender.setImage(UIImage(named: "star (1)"), for: UIControlState.normal)
            favouriteSessionIds.append(sessionId)
        }
    
        UserDefaults.standard.set(favouriteSessionIds, forKey: "Favourites")
        print(UserDefaults.standard.value(forKey: "Favourites")!)
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
                    vc.title = firstName + " " + lastName
                    let url = URL(string: speaker.value(forKey: "photoURL") as! String)
                    vc.speakerImageURL = url
                    vc.company = speaker.value(forKey: "organisation") as! String
                    vc.profile = speaker.value(forKey: "profile") as! String
                    vc.twitterURL = speaker.value(forKey: "twitter") as! String
                }
            }
            var talkArray = [sessionDetail]()
            let talkDesc = tableItem.description
            let buildingName = tableItem.locationName
            let sesTitle = tableItem.title
            vc.profileViewSelected = false
            let startTime =  Date().formatDate(dateToFormat: tableItem.untouchedDate)
            let timeStart = Date().wordedDate(Date: startTime)
            talkArray.append(sessionDetail(title: sesTitle, timeStarted: timeStart, buildingName: buildingName, talkDescription: talkDesc))

            
            vc.talks = talkArray
            vc.viewIsHidden = false
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
    private func setupAndRecieveCoreData() {
    
        self.scheduleSpinner.startAnimating()
        self.speakers = self.coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
        self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
        // TAGS
        self.tags = self.coreData.recieveCoreData(entityNamed: Entities.TAGS)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if self.tags.isEmpty || UserDefaults.standard.value(forKeyPath: "ModifiedDate") as! String != UserDefaults.standard.value(forKeyPath: "ModifiedTagsDate") as! String{
            
            if self.tags.isEmpty {print("Tags core data is empty, storing tags data...")} else {print("Tags core data is out of date, storing new tags data...")}
            self.api.storeTags(updateData: { () -> Void in
                self.tags = self.coreData.recieveCoreData(entityNamed: Entities.TAGS)
                self.scheduleSpinner.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.sortOutSections()
                self.sortOutTags()
            })
        } else {
            print("Tags core data is not empty & is up to date")
            self.scheduleSpinner.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.sortOutSections()
            self.sortOutTags()
        }
    }
    
    // Hellish function responsible for sorting out schedule data into seperate sections - Sorry that it is confusing, even to me...
    private func sortOutSections() {
        
        timeSections.removeAll()
        sortedSections.removeAll()
        
        if TagsStruct.tagsArray.isEmpty {
            TagsStruct.userIsFiltering = false
        }
        
        var completedTitles = [String]()
        completedTitles.removeAll()
        
        for item in sessions {
            
            // If user IS filtering by tags
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
                                self.timeSections[date] = [TableItem(title: title, date: dated, speakerId: speaker, day: day!, locationName: building, sessionId: sessionId, description: description, untouchedDate: untouchedDate, endDate: endDate)]
                                completedTitles.append(title)
                            } else {
                                if completedTitles.contains(title) == false{
                                    self.timeSections[date]!.append(TableItem(title: title, date: dated, speakerId: speaker, day: day!, locationName: building,  sessionId: sessionId, description: description, untouchedDate: untouchedDate, endDate: endDate))
                                    completedTitles.append(title)
                                }
                                
                            }
                        }
                        
                    }
                }
                
            } // If user is NOT filtering by tags
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
                    self.timeSections[date] = [TableItem(title: title, date: dated, speakerId: speaker, day: day!, locationName: building, sessionId: sessionId, description: description, untouchedDate: untouchedDate, endDate: endDate)]
                } else {
                    self.timeSections[date]!.append(TableItem(title: title, date: dated, speakerId: speaker, day: day!, locationName: building,  sessionId: sessionId, description: description, untouchedDate: untouchedDate, endDate: endDate))
                }
            }
        }
        
        for item in timeSections { sortedSections.append(item.key) }
        
        // Sort array in time order
        sortedSections = sortedSections.sorted {$0 < $1}
        // Update table
        scheduleTableView.reloadData()
    }
    
    // Get all tags in each session Id
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
    
    // MARK: - IBActions
    @IBAction func filterSessions(_ sender: Any) {
        
        let vc = revealViewController().rearViewController as! FilterViewController
        
        switch sessionSegment.selectedSegmentIndex{
        case 0 :
            TagsStruct.date = "2017-04-18"
            scheduleTableView.reloadData()
            if vc.isViewLoaded == true {
                vc.filterTableView.reloadData()
            }
        case 1 :
            TagsStruct.date = "2017-04-19"
            scheduleTableView.reloadData()
            if vc.isViewLoaded == true {
              vc.filterTableView.reloadData()
            }
        default :
            TagsStruct.date = "2017-04-20"
            scheduleTableView.reloadData()
            if vc.isViewLoaded == true {
                vc.filterTableView.reloadData()
            }
        }
    }
    
    // MARK: - UI
    private func setupSideMenu() {
        
        openBtn.target = self.revealViewController()
        openBtn.action = #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    private func setupUI() {
        
        sessionSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
        sessionSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        scheduleSpinner.hidesWhenStopped = true
        scheduleTableView.tableFooterView = UIView()
    }
    
    private func checkDateAndSetSegment() {
        
        switch (TagsStruct.date){
        case "2017-04-18" :  sessionSegment.selectedSegmentIndex = 0
        case "2017-04-19" :  sessionSegment.selectedSegmentIndex = 1
        case "2017-04-20" :  sessionSegment.selectedSegmentIndex = 2
        default: sessionSegment.selectedSegmentIndex = 0
        }
    }
}

// MARK: - Session TableViewCell Controller
class FullWidthCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var sessionFullNameLbl: UILabel!
    @IBOutlet weak var buildingIconImgView: UIImageView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var favouriteButton: UIButton!
    
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

// Mark: - Tag CollectionViewCell Controller
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
    let endDate : String
}

// MARK: - Tags Model
struct SessionTags {
    
    let title: String
    let tagId : Int
}
