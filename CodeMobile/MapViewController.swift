//
//  MapViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 27/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var locationCollectionView: UICollectionView!
    
    var locationsArray = [Locations]()
   
    
    // MARK: View Controller Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
         locationsArray = [Locations(sectionName:"Points of Interest", locationNames: ["Beswick", "Molloy", "Town Hall", "Queen's Hotel"], miles: ["1", "2", "3", "4"], imagesURLs: ["!£!@£@!", "123!@", "!@£!@l", "!@£!@l"]), Locations(sectionName:"Transport", locationNames: ["Abbey Taxis", "Bus Station", "Kingkabs", "Train Station"], miles: ["1", "2", "3","4"], imagesURLs: ["!£!@£@!", "123!@", "!@£!@l", "!@£!@l"])]
        
      
    }
    
    override func viewDidLoad() {
        
    }
    
    //  MARK: Collection View Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return locationsArray[section].locationNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = locationCollectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.locationNameLbl.text = locationsArray[indexPath.section].locationNames[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return CGSize(width: view.frame.size.width / 2 - 10, height: view.frame.size.width / 2 - 10)

        case .pad:   return CGSize(width: view.frame.size.width / 4 - 10, height: view.frame.size.width / 4 - 10)

    
        case .unspecified: return CGSize(width: view.frame.size.width / 2 - 10, height: view.frame.size.width / 2 - 10)
          
        default: return CGSize(width: view.frame.size.width / 2 - 10, height: view.frame.size.width / 2 - 10)
        }
        
  
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
          return locationsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "LocationCellHeader",
                                                                             for: indexPath) as! LocationCellHeader
            headerView.sectionHeaderLbl.text = locationsArray[(indexPath as NSIndexPath).section].sectionName
            
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }

    }
    
}
// MARK: Location CollectionView Cell UI
class LocationCell : UICollectionViewCell {
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var milesLbl: UILabel!
}
// MARK: Location CollectionView Header UI
class LocationCellHeader : UICollectionReusableView {
    
    @IBOutlet weak var sectionHeaderLbl: UILabel!
}
// MARK: Location Model
struct Locations {
    
    var sectionName : String!
    var locationNames : [String]!
    var miles : [String]!
    var imagesURLs : [String]!
}


