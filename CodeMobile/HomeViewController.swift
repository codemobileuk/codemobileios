//
//  HomeViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 20/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISplitViewControllerDelegate   {
    
    // MARK: - Properties
    private let api = ApiHandler()
    private let coreData = CoreDataHandler()
    private var sessions: [NSManagedObject] = []
    private var speakers: [NSManagedObject] = []
    private var currentlyOnSessions: [NSManagedObject] = []
    private var lastSelectedIndex = IndexPath()
    private var fromSchedule = Bool()
    private var viewBugFixed = false // BUG: - Collection views are clipped when rotating, and on second load view everything bugs out
    private var hasInitiliallyLoaded = false
    private var isGrantedNotificationAccess:Bool = false
    private var isEventOver = false
    private var noSessionsOn = false
    
    @IBOutlet weak var currentlyOnCollectionView: UICollectionView!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var bannerBackground: UIView!
    @IBOutlet weak var scheduleSpinner: UIActivityIndicatorView!
    @IBOutlet weak var currentlyOnSpinner: UIActivityIndicatorView!
    
    // MARK: - View Controller Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        
        if UserDefaults.standard.value(forKey: "Feedbackform") == nil {
        
            UserDefaults.standard.set(false, forKey: "Feedbackform")
        }
        //scheduleCollectionView.reloadData()
        //currentlyOnCollectionView.reloadData()
        setupUI()
        // Refresh to see if new session has started
        
        if hasInitiliallyLoaded == true {
            self.tabBarController?.tabBar.isUserInteractionEnabled = false
            setupAndRecieveCoreData()
        } else {
            self.launchReviewFormAlert()
        }
        setupSplitView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        hasInitiliallyLoaded = true
         checkForUpdateAndThenSetupAndRecieveCoreData()
    }
    
    override func viewDidLoad() {
        
        setupUI()
        // User cannot switch tabs until data has been retrieved
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        setupSplitView()
        
    }
    
    
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.scheduleCollectionView.setNeedsDisplay()
        scheduleCollectionView.layoutIfNeeded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .default
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            self.scheduleCollectionView.setNeedsDisplay()
            scheduleCollectionView.layoutIfNeeded()
            if viewBugFixed == false {
                loadView()
                loadView()
                loadView()
                viewBugFixed = true
            } else {
                loadView()
            }
            scheduleSpinner.hidesWhenStopped = true
            currentlyOnSpinner.hidesWhenStopped = true
            
        } else {
            print("Portrait")
            self.scheduleCollectionView.setNeedsDisplay()
            scheduleCollectionView.layoutIfNeeded()
            if viewBugFixed == false {
                loadView()
                loadView()
                loadView()
                viewBugFixed = true
            } else {
                loadView()
            }
            scheduleSpinner.hidesWhenStopped = true
            currentlyOnSpinner.hidesWhenStopped = true
        }
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == currentlyOnCollectionView {
            if noSessionsOn == true {
                return 1
            }else{
                return currentlyOnSessions.count
            }
        } else {
        
            if isEventOver == true{
            
                return 1
            }
            else {
                return sessions.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == scheduleCollectionView { // Schedule Collection View
            
            if isEventOver == true{
                
                print("CodeMobile has finished!")
                let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "Finished", for: indexPath) as UICollectionViewCell
                return cell
                
            } else
            {
                
                let item = sessions[indexPath.row]
                let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrentlyOn", for: indexPath) as! SessionCollectionCell
                cell.sessionTitleLbl.text = (item.value(forKey: "SessionTitle") as! String?)! + "\n"
                cell.speakerImageView.setRadius(radius: 20.0)
                let startTime = Date().formatDate(dateToFormat: item.value(forKey: "SessionStartDateTime")! as! String)
                let endTime = Date().formatDate(dateToFormat: item.value(forKey: "SessionEndDateTime")! as! String)
                
                if Date().isBetweeen(date: startTime, andDate: endTime) {
                    //Session is on
                    cell.liveInWhichBuildingLbl.text = "On Now - \(item.value(forKey: "sessionLocationName")! as! String)"
                    cell.liveInWhichBuildingLbl.textColor = UIColor.red
                } else {
                    //Session is off
                    cell.liveInWhichBuildingLbl.textColor = UIColor.blue
                    cell.liveInWhichBuildingLbl.text = Date().wordedDate(Date: startTime)
                }
                
                for speaker in speakers {
                    
                    if speaker.value(forKey: "speakerId") as! Int == item.value(forKey: "speakerId") as! Int{
                        let firstName = speaker.value(forKey: "firstname") as! String
                        let lastName = speaker.value(forKey: "surname") as! String
                        cell.speakerNameLbl.text = firstName + " " + lastName
                        let url = URL(string: speaker.value(forKey: "photoURL") as! String)
                        cell.speakerImageView.kf.setImage(with: url)
                        cell.speakerImageView.contentMode = .scaleAspectFill
                    }
                }
                return cell
            }
            
        } else { // Currently On Collection View
            
            if noSessionsOn == true { // No sessions on
                
                let cell = currentlyOnCollectionView.dequeueReusableCell(withReuseIdentifier: "NoSession", for: indexPath) as! NoSessionCollectionCell
                
                UIView.animate(withDuration: 0, animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }) { (finished) in
                    UIView.animate(withDuration: 0, animations: {
                        cell.transform = CGAffineTransform.identity
                    })
                }
                
                return cell
            }
                
            else if currentlyOnSessions.count == 1 { // 1 session on
                
                let item = currentlyOnSessions[indexPath.row]
                let cell = currentlyOnCollectionView.dequeueReusableCell(withReuseIdentifier: "SingleSession", for: indexPath) as! SingleSessionCollectionCell
                cell.sessionTitleLbl.text = item.value(forKey: "SessionTitle") as! String?
                cell.liveInWhichBuildingLbl.text = "On Now - \(item.value(forKey: "sessionLocationName")! as! String)"
                cell.speakerImageView.setRadius(radius: 20.0)
                for speaker in speakers {
                    
                    if speaker.value(forKey: "speakerId") as! Int == item.value(forKey: "speakerId") as! Int{
                        let firstName = speaker.value(forKey: "firstname") as! String
                        let lastName = speaker.value(forKey: "surname") as! String
                        cell.speakerNameLbl.text = firstName + " " + lastName
                        let url = URL(string: speaker.value(forKey: "photoURL") as! String)
                        cell.speakerImageView.kf.setImage(with: url)
                        cell.speakerImageView.contentMode = .scaleAspectFill
                    }
                }
                cell.sessionInfoLbl.text = item.value(forKey: "sessionDescription") as! String?
                
                return cell
                
            } else { // 2 sessions on
                
                let item = currentlyOnSessions[indexPath.row]
                let cell = currentlyOnCollectionView.dequeueReusableCell(withReuseIdentifier: "DuelSessions", for: indexPath) as! DueliPhoneCollectionCell
                cell.sessionTitleLbl.text = item.value(forKey: "SessionTitle") as! String?
                cell.liveInWhichBuildingLbl.text = "On Now - \(item.value(forKey: "sessionLocationName")! as! String)"// + "\n"
                cell.speakerImageView.setRadius(radius: 20.0)
                for speaker in speakers {
                    
                    if speaker.value(forKey: "speakerId") as! Int == item.value(forKey: "speakerId") as! Int{
                        let firstName = speaker.value(forKey: "firstname") as! String
                        let lastName = speaker.value(forKey: "surname") as! String
                        cell.speakerNameLbl.text = firstName + " " + lastName
                        let url = URL(string: speaker.value(forKey: "photoURL") as! String)
                        cell.speakerImageView.kf.setImage(with: url)
                        cell.speakerImageView.contentMode = .scaleAspectFill
                        
                    }
                }
                
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == currentlyOnCollectionView && currentlyOnSessions.count < 2{
            return CGSize(width: currentlyOnCollectionView.frame.size.width - 10, height: currentlyOnCollectionView.frame.size.height)
        }
        if collectionView == currentlyOnCollectionView {
            return CGSize(width: currentlyOnCollectionView.frame.size.width / 2 - 10, height: currentlyOnCollectionView.frame.size.height)
        }
        if collectionView == scheduleCollectionView && sessions.isEmpty {
            return CGSize(width: scheduleCollectionView.frame.size.width - 10, height: scheduleCollectionView.frame.size.height)
        }
        return CGSize(width: scheduleCollectionView.frame.size.width / 2.25 , height: scheduleCollectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        lastSelectedIndex = indexPath
        if collectionView == scheduleCollectionView {
            fromSchedule = true
            UIView.animate(withDuration: 0.1, animations: {
                cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { (finished) in
                UIView.animate(withDuration: 0.1, animations: {
                    cell?.transform = CGAffineTransform.identity
                    self.performSegue(withIdentifier: "showHomeDetail", sender: self)
                })
            }
            
        } else if collectionView == currentlyOnCollectionView && currentlyOnSessions.isEmpty == false{
            fromSchedule = false
            UIView.animate(withDuration: 0.1, animations: {
                cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { (finished) in
                UIView.animate(withDuration: 0.1, animations: {
                    cell?.transform = CGAffineTransform.identity
                    self.performSegue(withIdentifier: "showHomeDetail", sender: self)
                })
            }
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showHomeDetail" {
            
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers[0] as! DetailViewController
            var session : NSManagedObject
            if fromSchedule == true {
                session = sessions[(lastSelectedIndex.row)]
            } else {
                session = currentlyOnSessions[(lastSelectedIndex.row)]
            }
            vc.extendedLayoutIncludesOpaqueBars = true
            for speaker in speakers {
                // Find speakerId in speaker array and collect relevent information to match session
                if speaker.value(forKey: "speakerId") as! Int == session.value(forKey: "speakerId") as! Int{
                    
                    let firstName = speaker.value(forKey: "firstname") as! String
                    let lastName = speaker.value(forKey: "surname") as! String
                    vc.fullname = firstName + " " + lastName
                    vc.title = firstName + " " + lastName
                    let url = URL(string: speaker.value(forKey: "photoURL") as! String)
                    vc.speakerImageURL = url
                    vc.company = speaker.value(forKey: "organisation") as! String
                    vc.profile = speaker.value(forKey: "profile") as! String
                    if speaker.value(forKey: "twitter") as? String != nil {
                        vc.twitterURL = speaker.value(forKey: "twitter") as! String
                    }
                }
            }
            
            var talkArray = [sessionDetail]()
            let talkDesc = session.value(forKey: "sessionDescription") as! String
            let buildingName = session.value(forKey: "sessionLocationName") as! String!
            let sesTitle = session.value(forKey: "sessionTitle") as! String!
            vc.profileViewSelected = false
            vc.viewIsHidden = false
            let startTime = Date().formatDate(dateToFormat: session.value(forKey: "sessionStartDateTime") as! String!)
            let timeStart = Date().wordedDate(Date: startTime)
            talkArray.append(sessionDetail(title: sesTitle!, timeStarted: timeStart, buildingName: buildingName!, talkDescription: talkDesc))
            
            vc.talks = talkArray
        }
    }
    
    // MARK: - Core Data
    private func checkForUpdateAndThenSetupAndRecieveCoreData() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.scheduleSpinner.startAnimating()
        self.currentlyOnSpinner.startAnimating()
        api.getLatestApiVersion {
            
            self.setupAndRecieveCoreData()
        }
    }
    
    private func setupAndRecieveCoreData() {
        
        self.scheduleSpinner.startAnimating()
        self.currentlyOnSpinner.startAnimating()
        self.currentlyOnSessions.removeAll()
        // SPEAKERS
        // Recieve speaker data from core data
        self.speakers = self.coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
        // Check if data contains data, if not retrieve data from the API then store the data into speaker array.
        if self.speakers.isEmpty || UserDefaults.standard.value(forKeyPath: "ModifiedDate") as! String != UserDefaults.standard.value(forKeyPath: "ModifiedSpeakersDate") as! String{
            
            if speakers.isEmpty {print("Speakers core data is empty, storing speakers data...")}else {print("Speakers core data is out of date, storing new speakers data...")}
            self.api.storeSpeakers(updateData: { () -> Void in
                // When data has been successfully stored
                self.speakers = self.coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
                self.scheduleCollectionView.reloadData()
                for (i,num) in self.speakers.enumerated().reversed() {
                    if num.value(forKey: "firstname") as! String == "Break"{
                        self.speakers.remove(at: i)
                    }
                }
                
            })
        } else {print("Speakers core data is not empty & is up to date")}
        
        // SESSIONS
        self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if self.sessions.isEmpty || UserDefaults.standard.value(forKeyPath: "ModifiedDate") as! String != UserDefaults.standard.value(forKeyPath: "ModifiedScheduleDate") as! String{
            
            if self.sessions.isEmpty { print("Schedule core data is empty, storing schedule data...")} else {print("Schedule core data is out of date, storing new schedule data...") }
            self.api.storeSchedule(updateData: { () -> Void in
                self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
                for (i,num) in self.sessions.enumerated().reversed() {
                    // Remove past sessions
                    let endTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionEndDateTime")! as! String)
                    if endTime < Date() {
                        self.sessions.remove(at: i)
                    }// Remove breaks
                    else if num.value(forKey: "SessionTitle") as! String == "Break" || num.value(forKey: "SessionTitle") as! String == "Lunch" || num.value(forKey: "SessionTitle") as! String == "Tea / Coffee / Registration"{
                        self.sessions.remove(at: i)
                    }else{
                        let startTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionStartDateTime")! as! String)
                        
                        if Date().isBetweeen(date: startTime, andDate: endTime) {
                            //Session is on
                            self.currentlyOnSessions.append(num)
                            print("\(String(describing: num.value(forKey: "SessionTitle"))) is on!")
                            self.sessions.remove(at: i)
                            
                        } else {
                            if #available(iOS 10.0, *) {
                                UNUserNotificationCenter.current().requestAuthorization(
                                    options: [.alert,.sound,.badge],
                                    completionHandler: { (granted,error) in
                                        self.isGrantedNotificationAccess = granted
                                        let startTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionStartDateTime")! as! String)
                                        let sessionTitle = num.value(forKey: "SessionTitle") as! String
                                        let buildingName = num.value(forKey: "sessionLocationName") as! String
                                        self.notificationSquad(date: startTime, sessionTalk: sessionTitle, building: buildingName)
                                }
                                )
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                }
                if self.sessions.isEmpty {
                    self.isEventOver = true
                } else {
                    self.isEventOver = false
                }
                if self.currentlyOnSessions.isEmpty {
                    self.noSessionsOn = true
                } else {
                    self.noSessionsOn = false
                }

                self.scheduleCollectionView.reloadData()
                self.currentlyOnCollectionView.reloadData()
                self.scheduleSpinner.stopAnimating()
                self.currentlyOnSpinner.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tabBarController?.tabBar.isUserInteractionEnabled = true
            })
        } else {
            print("Schedule core data is not empty & is up to date")
            
            for (i,num) in self.sessions.enumerated().reversed() {
                // Remove past sessions
                let endTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionEndDateTime")! as! String)
                if endTime < Date() {
                    self.sessions.remove(at: i)
                }// Remove breaks
                else if num.value(forKey: "SessionTitle") as! String == "Break" || num.value(forKey: "SessionTitle") as! String == "Lunch" || num.value(forKey: "SessionTitle") as! String == "Tea / Coffee / Registration"{
                    self.sessions.remove(at: i)
                } else{
                    let startTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionStartDateTime")! as! String)
                    
                    if Date().isBetweeen(date: startTime, andDate: endTime) {
                        //Session is on
                        self.currentlyOnSessions.append(num)
                        print("\(String(describing: num.value(forKey: "SessionTitle"))) is on!")
                        self.sessions.remove(at: i)
                        
                    } else {
                        //Session is off
                    }
                    
                }
                
                
            }
            if self.sessions.isEmpty {
                self.isEventOver = true
            } else {
                 self.isEventOver = false
            }
            if self.currentlyOnSessions.isEmpty {
                self.noSessionsOn = true
            } else {
                self.noSessionsOn = false
            }
            self.scheduleSpinner.stopAnimating()
            self.currentlyOnSpinner.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
           
        }
        self.scheduleCollectionView.reloadData()
        self.currentlyOnCollectionView.reloadData()
       
    }
    
    // MARK: - SplitView
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    
    private func setupSplitView(){
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    }
    
    // MARK: - IBActions
    @IBAction func viewWebsite(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showWebsite", sender: self)
    }
    
    @IBAction func viewSchedule(_ sender: Any) {
        
        tabBarController?.selectedIndex = 1
    }
    
    // MARK: - UI
    private func setupUI() {
        
        scheduleSpinner.hidesWhenStopped = true
        currentlyOnSpinner.hidesWhenStopped = true
    }
    
    // MARK: - Notifications
    @available(iOS 10.0, *)
    func notificationSquad(date: Date, sessionTalk: String, building: String ) {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let content = UNMutableNotificationContent()
        content.title = sessionTalk
        content.subtitle = "in \(building)"
        content.body = "Starting in 5 minutes!"
        content.badge = 1
        
        let requestIdentifier = "demoNotification"
        
        var date = DateComponents()
        if newComponents.minute == 0 {
            date.hour = newComponents.hour! - 1
             date.minute = newComponents.minute! + 55
        } else {
            date.minute = newComponents.minute! - 5
            date.hour = newComponents.hour
        }
        date.day = newComponents.day
        date.year = newComponents.year
        date.month = newComponents.month
        
        print("Notification set for date: \(date)")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        
    }
    
    // MARK: - AlertView
    func launchReviewFormAlert() {
    
        if Date() >= Date().formatDate(dateToFormat:"2018-04-05T11:58:48") {
            
            if UserDefaults.standard.value(forKey: "Feedbackform") as! Bool == false{
                // create the alert
                let alert = UIAlertController(title: "Feedback form", message: "Would you like to fill out a short form and give us your thoughts on CodeMobile 2018?", preferredStyle: UIAlertControllerStyle.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertActionStyle.cancel, handler: { action in
                    
                    UserDefaults.standard.set(true, forKey: "Feedbackform")
                }))

                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                    
                    UserDefaults.standard.set(true, forKey: "Feedbackform")
                    let url = URL(string: Commands.FORM_URL)
                    if UIApplication.shared.canOpenURL(url!) {
                        if #available(iOS 10.0, *) {
                            UserDefaults.standard.set(true, forKey: "Feedbackform")
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                            UIApplication.shared.open(url!, options: [:], completionHandler: { (success) in
                                print("Open url : \(success)")
                            })

                        } else {
                            // Fallback on earlier versions
                        }
                        //If you want handle the completion block than
                    }
                    
                    
                }))
                alert.addAction(UIAlertAction(title: "Remind Me later", style: UIAlertActionStyle.default, handler: { action in
                    
                    // do something like...
                    UserDefaults.standard.set(false, forKey: "Feedbackform")
                  
                    
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Schedule CollectionViewCell Controller
class SessionCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var liveInWhichBuildingLbl: UILabel!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var sessionTitleLbl: UILabel!
}

// MARK: - Tweet CollectionViewCell Controller
class TweetCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var twitterUserLbl: UILabel!
}

// MARK: - Duel iPhone CollectionViewCell Controller
class DueliPhoneCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var liveInWhichBuildingLbl: UILabel!
}

class SingleSessionCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var liveInWhichBuildingLbl: UILabel!
    @IBOutlet weak var sessionInfoLbl: UILabel!
    
}

class NoSessionCollectionCell: UICollectionViewCell {
    
}

