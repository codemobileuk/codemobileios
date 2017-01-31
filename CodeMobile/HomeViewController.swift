//
//  HomeViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 20/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var tweetsCollectionView: UICollectionView!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var bannerBackground: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.navigationItem.title = "Home"
        tabBarController?.navigationItem.rightBarButtonItem = nil
         
    }
    
    //  MARK: Collection View Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrentlyOn", for: indexPath)
        
        if collectionView == scheduleCollectionView {
        let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrentlyOn", for: indexPath)
        return cell
        }
        else if collectionView == tweetsCollectionView {
            
            let cell = tweetsCollectionView.dequeueReusableCell(withReuseIdentifier: "TweetCell", for: indexPath)
            return cell

        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == tweetsCollectionView {
            return CGSize(width: 320 , height: 80)
        }
        return CGSize(width: 170 , height: scheduleCollectionView.frame.size.height)
    }
}
