//
//  HomeViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 20/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var scheduleView: UIView!
   
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.navigationItem.title = "Home"
    }
    @IBAction func switchToSpeakerTab(_ sender: Any) {
        
        print("Speaker tab btn tapped")
    }
  
    @IBAction func switchToScheduleTab(_ sender: Any) {
        
        print("Schedule tab btn tapped")
    }
    
    @IBAction func switchToMapTab(_ sender: Any) {
        
        print("Map tab btn tapped")
    }
    
    // Collection View Functions
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrentlyOn", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: scheduleCollectionView.frame.size.width/2 - 2.5, height: scheduleView.frame.size.height)
    }
    
    
}
