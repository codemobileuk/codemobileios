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
    var isGrantedNotificationAccess:Bool = false
    
    @IBOutlet weak var currentlyOnCollectionView: UICollectionView!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var bannerBackground: UIView!
    @IBOutlet weak var scheduleSpinner: UIActivityIndicatorView!
    @IBOutlet weak var currentlyOnSpinner: UIActivityIndicatorView!
    
    // MARK: - View Controller Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        
        scheduleCollectionView.reloadData()
        currentlyOnCollectionView.reloadData()
        setupUI()
        // User cannot switch tabs until data has been retrieved
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        setupAndRecieveCoreData()
        setupSplitView()
    }
    
    @available(iOS 10.0, *)
    func notificationSquad(date: Date) {
    
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        print(newComponents.date)
        
        let content = UNMutableNotificationContent()
        content.title = "Meeting Reminder"
        content.subtitle = "Meeting Reminder"
        content.body = "Don't forget to bring coffee."
        content.badge = 1
        
        let requestIdentifier = "demoNotification"
        
        var date = DateComponents()
        date.hour = newComponents.hour
        date.minute = newComponents.minute
        date.day = newComponents.day
        date.year = newComponents.year
        date.month = newComponents.month
        
        date.hour = 15
        date.minute = 40
        date.day = 28
        date.year = 2017
        date.month = 3
        
        print(date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)

    
    }
    
    override func viewDidLoad() {
        
        setupUI()
        // User cannot switch tabs until data has been retrieved
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        setupSplitView()
        //setupAndRecieveCoreData()
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
            if currentlyOnSessions.isEmpty {
                return 1
            }else{
                return currentlyOnSessions.count
            }
        }
        return sessions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == scheduleCollectionView { // Schedule Collection View
            
            let item = sessions[indexPath.row]
            let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrentlyOn", for: indexPath) as! SessionCollectionCell
            cell.sessionTitleLbl.text = item.value(forKey: "SessionTitle") as! String?
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
                }
            }
            return cell
            
        } else { // Currently On Collection View
            
            if currentlyOnSessions.count == 0 { // No sessions on
                
                let cell = currentlyOnCollectionView.dequeueReusableCell(withReuseIdentifier: "NoSession", for: indexPath) as! NoSessionCollectionCell
                
                UIView.animate(withDuration: 0, animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }) { (finished) in
                    UIView.animate(withDuration: 0.2, animations: {
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
                    }
                }
                cell.sessionInfoLbl.text = item.value(forKey: "sessionDescription") as! String?
                
                return cell
                
            } else { // 2 sessions on
                
                let item = currentlyOnSessions[indexPath.row]
                let cell = currentlyOnCollectionView.dequeueReusableCell(withReuseIdentifier: "DuelSessions", for: indexPath) as! DueliPhoneCollectionCell
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
                }
            }
            var descArray = [String]()
            descArray.append(session.value(forKey: "sessionDescription") as! String)
            vc.buildingName = session.value(forKey: "sessionLocationName") as! String
            vc.talkName = session.value(forKey: "sessionTitle") as! String
            vc.talks = descArray
            vc.profileViewSelected = false
            vc.viewIsHidden = false
            let startTime = Date().formatDate(dateToFormat: session.value(forKey: "sessionStartDateTime") as! String)
            vc.timeStarted = Date().wordedDate(Date: startTime)
        }
    }
    
    // MARK: - Core Data
    private func setupAndRecieveCoreData() {
        
        if Reachability.isConnectedToNetwork() {
        
            print("Connected")
        } else {
        
            print("Not connected")
        }
        
        api.getLatestApiVersion {
            
            self.scheduleSpinner.startAnimating()
            self.currentlyOnSpinner.startAnimating()

            self.currentlyOnSessions.removeAll()
            // SPEAKERS
            // Recieve speaker data from core data
            self.speakers = self.coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
            // Check if data contains data, if not retrieve data from the API then store the data into speaker array.
            if self.speakers.isEmpty || UserDefaults.standard.value(forKeyPath: "ModifiedId") as! Int != UserDefaults.standard.value(forKeyPath: "ModifiedSpeakersId") as! Int{
                print("Speakers core data is empty, storing speakers data...")
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
            } else {print("Speakers core data is not empty")}
            
            // SESSIONS
            self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            if self.sessions.isEmpty || UserDefaults.standard.value(forKeyPath: "ModifiedId") as! Int != UserDefaults.standard.value(forKeyPath: "ModifiedScheduleId") as! Int{
                print("Schedule core data is empty, storing schedule data...")
                self.api.storeSchedule(updateData: { () -> Void in
                    self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
                    for (i,num) in self.sessions.enumerated().reversed() {
                        // Remove past sessions
                        let endTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionEndDateTime")! as! String)
                        if endTime < Date() {
                            self.sessions.remove(at: i)
                        }// Remove breaks
                        else if num.value(forKey: "SessionTitle") as! String == "Break"{
                            self.sessions.remove(at: i)
                        }else{
                            let startTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionStartDateTime")! as! String)
                            
                            if Date().isBetweeen(date: startTime, andDate: endTime) {
                                //Session is on
                                self.currentlyOnSessions.append(num)
                                print("\(num.value(forKey: "SessionTitle")) is on!")
                                self.sessions.remove(at: i)
                                
                            } else {
                                if #available(iOS 10.0, *) {
                                    UNUserNotificationCenter.current().requestAuthorization(
                                        options: [.alert,.sound,.badge],
                                        completionHandler: { (granted,error) in
                                            self.isGrantedNotificationAccess = granted
                                            let startTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionStartDateTime")! as! String)
                                            self.notificationSquad(date: startTime)
                                    }
                                    )
                                } else {
                                    // Fallback on earlier versions
                                }


                            }
                            
                        }
                        
                        
                    }
                    self.scheduleCollectionView.reloadData()
                    self.currentlyOnCollectionView.reloadData()
                    self.scheduleSpinner.stopAnimating()
                    self.currentlyOnSpinner.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.tabBarController?.tabBar.isUserInteractionEnabled = true
                    
                })
            } else {
                print("Schedule core data is not empty")
                
                for (i,num) in self.sessions.enumerated().reversed() {
                    // Remove past sessions
                    let endTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionEndDateTime")! as! String)
                    if endTime < Date() {
                        self.sessions.remove(at: i)
                    }// Remove breaks
                    else if num.value(forKey: "SessionTitle") as! String == "Break"{
                        self.sessions.remove(at: i)
                    } else{
                        let startTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionStartDateTime")! as! String)
                        
                        if Date().isBetweeen(date: startTime, andDate: endTime) {
                            //Session is on
                            self.currentlyOnSessions.append(num)
                            print("\(num.value(forKey: "SessionTitle")) is on!")
                            self.sessions.remove(at: i)
                            
                        } else {
                            //Session is off
                        }
                        
                    }
                    
                    
                }
                self.scheduleSpinner.stopAnimating()
                self.currentlyOnSpinner.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tabBarController?.tabBar.isUserInteractionEnabled = true
            }
            
            self.scheduleCollectionView.reloadData()
            self.currentlyOnCollectionView.reloadData()
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

