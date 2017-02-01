//
//  HomeViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 20/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //  let url = URL(string: speaker.value(forKey: "photoURL") as! String)
    //  cell.buildingIconImgView.kf.setImage(with: url)

    @IBOutlet weak var tweetsCollectionView: UICollectionView!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var bannerBackground: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.navigationItem.title = "Home"
        tabBarController?.navigationItem.rightBarButtonItem = nil
        
     
        scheduleCollectionView.reloadData()
        tweetsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        setupScheduleData()

    }
    
    private let api = ApiHandler()
    private let coreData = CoreDataHandler()
    
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
                self.scheduleCollectionView.reloadData()
            })
        } else {print("Speakers core data is not empty")}
        
        // Sessions Core Data - Repeated for session information
        sessions = coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
        
        if sessions.isEmpty{
            print("Schedule core data is empty, storing schedule data...")
            api.storeSchedule(updateData: { () -> Void in
                self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
                self.scheduleCollectionView.reloadData()
            })
        } else {
            print("Schedule core data is not empty")
           
        }
    }

    //  MARK: Collection View Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return sessions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       // let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrentlyOn", for: indexPath)
        
        if collectionView == scheduleCollectionView {
            let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrentlyOn", for: indexPath) as! SessionCollectionCell
            
            let item = sessions[indexPath.row]
            cell.sessionTitleLbl.text = item.value(forKey: "SessionTitle") as! String?
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
        else  {
            
            let cell = tweetsCollectionView.dequeueReusableCell(withReuseIdentifier: "TweetCell", for: indexPath) as! TweetCollectionCell
            cell.setRadius(radius: 5.0)
            return cell
        }
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == tweetsCollectionView {
            return CGSize(width: 320 , height: 60)
        }
        return CGSize(width: 170 , height: scheduleCollectionView.frame.size.height)
    }
}

// Class to represent UI of schedule collection cell
class SessionCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var liveInWhichBuildingLbl: UILabel!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var sessionTitleLbl: UILabel!
}
// Class to represent UI of tweet collection cell
class TweetCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var twitterUserLbl: UILabel!
}
