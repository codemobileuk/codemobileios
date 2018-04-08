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

class MapDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    var locationPoints = [CLLocationCoordinate2D]()
    var lat = 53.1938717
    var long = -2.8961019
    var annotationSections = [AnnotationItem]()
    var selectedTitle = ""
    var selectedSubtitle = ""
    private let locationManager = CLLocationManager()
    private let regionRadius: CLLocationDistance = 1000
    
    @IBOutlet weak var chesterMapView: MKMapView!
    @IBOutlet weak var mapTypeSegment: UISegmentedControl!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        
        setupUI()
        setupInitialLocation()
        setupLocationManager()
        addAnnotations()
    }
    
    // MARK: - Initialization
    private func setupInitialLocation() {
        
        let initialLocation = CLLocation(latitude: lat, longitude: long)
        centerMapOnLocation(location: initialLocation)
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        chesterMapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func addAnnotations() {
        
        var annotations = [MKPointAnnotation]()
        
        for item in annotationSections {
            
            if item.locationName == selectedTitle {
                
                let startingAnnotation = MKPointAnnotation()
                startingAnnotation.title = selectedTitle
                startingAnnotation.subtitle = selectedSubtitle
                startingAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat,longitude: long)
                chesterMapView.addAnnotation(startingAnnotation)
                chesterMapView.selectAnnotation(startingAnnotation, animated: true)
                
            }else {
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: item.latitude,longitude: item.longitude)
                annotation.title = item.locationName
                annotation.subtitle = item.description
                annotations.append(annotation)
            }
            
        }
        
        chesterMapView.addAnnotations(annotations)
    }
    
    private func setupLocationManager() {
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.chesterMapView.showsUserLocation = true
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        _ = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        //self.chesterMapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: - IBActions
    @IBAction func changeMapType(_ sender: Any) {
        
        switch mapTypeSegment.selectedSegmentIndex{
        case 0 : chesterMapView.mapType = MKMapType.standard
        case 1 : chesterMapView.mapType = MKMapType.satellite
        default : chesterMapView.mapType = MKMapType.hybrid
        }
    }
    
    // MARK: - UI
    private func setupUI() {
        
        mapTypeSegment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState.selected)
        mapTypeSegment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState.normal)
    }
}
