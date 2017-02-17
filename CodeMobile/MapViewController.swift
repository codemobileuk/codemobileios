//
//  MapViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 27/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var locationTableView: UITableView!
    
    private let coreData = CoreDataHandler()
    
    // MARK: - View Controller Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        locationTableView.reloadData()
    }
    
    override func viewDidLoad() {
        
        recieveCoreData()
        setupSplitView()
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return locationSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locationSections[sortedSections[section]]!.count
    }
    
    var toBeAnnotations = [CLLocationCoordinate2D]()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableSection = locationSections[sortedSections[indexPath.section]]
        let tableItem = tableSection![0]
        let cell = self.locationTableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let url = URL(string: tableItem.thumbnailImage)
        cell.locationThumbnailImageView.kf.setImage(with: url)
        cell.locationThumbnailImageView.setRadius(radius: 5)
        
        cell.locationNameLbl.text = tableItem.locationName
        cell.milesLbl.text = tableItem.description
        toBeAnnotations.append(CLLocationCoordinate2D(latitude: tableItem.latitude,longitude: tableItem.longitude))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let tableSection = locationSections[sortedSections[section]]
        let tableItem = tableSection![0]
        
        return tableItem.type
    }
    
    // MARK: - SplitView
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    
    private func setupSplitView(){
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMapDetail" {
            
            let index = self.locationTableView.indexPathForSelectedRow! as NSIndexPath
            let tableSection = locationSections[sortedSections[index.section]]
            let tableItem = tableSection![index.row]
            
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers[0] as! MapDetailViewController
            vc.extendedLayoutIncludesOpaqueBars = true
            // Pass data here
            vc.lat = tableItem.latitude
            vc.long = tableItem.longitude
            vc.locationPoints = toBeAnnotations
            
        }
    }

    
    // MARK: - Core Data
    
    private var locations: [NSManagedObject] = []
    
    private func recieveCoreData() {
        
        locations = coreData.recieveCoreData(entityNamed: Entities.LOCATIONS)
        sortOutSections()
    }
    
    private var locationSections = [String: [LocationItem]]()
    private var sortedSections = [String]()
    
    private func sortOutSections() {
        
        for item in locations {
            
            var locationName = String()
            var type = String()
            var thumbnailImage = String()
            var description = String()
            var latitude = Double()
            var longitude = Double()
            
            locationName = item.value(forKey: "locationName") as! String
            type = item.value(forKey: "type") as! String
            thumbnailImage = item.value(forKey: "imageURL") as! String
            description = item.value(forKey: "locationDescription") as! String
            latitude = item.value(forKey: "latitude") as! Double
            longitude = item.value(forKey: "longitude") as! Double
            
            
            // If array doesnt contain day/time of session add new key, else add TableItem to array to key already in array
            if self.locationSections.index(forKey: type) == nil {
                self.locationSections[type] = [LocationItem(locationName: locationName, type: type, thumbnailImage: thumbnailImage, description: description, latitude: latitude, longitude: longitude)]
            } else {
                self.locationSections[type]!.append(LocationItem(locationName: locationName, type: type, thumbnailImage: thumbnailImage, description: description, latitude: latitude, longitude: longitude))
            }
            
        }
        
        for item in locationSections { sortedSections.append(item.key) }
        
        // Sort array in time order
        sortedSections = sortedSections.sorted {$0 < $1}
        // Update table
        locationTableView.reloadData()
        
    }
}

// MARK: - Location TableView Cell UI
class LocationCell : UITableViewCell {
    
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var milesLbl: UILabel!
    @IBOutlet weak var locationThumbnailImageView: UIImageView!
    
}

// MARK: - Location Model TEST
struct Locations {
    
    var sectionName : String!
    var locationNames : [String]!
    var miles : [String]!
    var imagesURLs : [String]!
}
// MARK: - Location Model
struct LocationItem {
    
    let locationName: String
    let type : String
    let thumbnailImage : String
    let description : String
    let latitude : Double
    let longitude : Double
}


