//
//  MapDetailViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 10/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapDetailViewController: UIViewController {

    @IBOutlet weak var chesterMapView: MKMapView!
    @IBOutlet weak var mapTypeSegment: UISegmentedControl!
  
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        
        centerMapOnLocation(location: initialLocation)
        setupUI()
    }
    
    // MARK: - MapKit
    
    let initialLocation = CLLocation(latitude: 53.190391, longitude: -2.891635)
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        chesterMapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func changeMapType(_ sender: Any) {
        
        switch mapTypeSegment.selectedSegmentIndex{
        case 0 : chesterMapView.mapType = MKMapType.standard
        case 1 : chesterMapView.mapType = MKMapType.satellite
        default : chesterMapView.mapType = MKMapType.hybrid
        }
    }
    
    // MARK: - Other
    
    func setupUI() {
        
        mapTypeSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
        mapTypeSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
    }
}
