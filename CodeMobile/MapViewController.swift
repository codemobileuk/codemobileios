//
//  MapViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 27/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.navigationItem.title = "Map"
        tabBarController?.navigationItem.rightBarButtonItem = nil

    }
}
