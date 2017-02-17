//
//  FilterViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 08/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var filterTableView: UITableView!
    
    private var filtersArray = [Filters]()
    var filterItems = [Int]()
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filtersArray = [Filters(sectionName:"Days", sectionFilters: ["Tuesday 18th April", "Wednesday 19th April", "Thursday 20th April"]),Filters(sectionName:"Tags", sectionFilters: ["iOS", "Android", "Design", "Security", "Other"]),]
        filterTableView.tableFooterView = UIView()
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return filtersArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filtersArray[section].sectionFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.filterTableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.filterTitleLabel.text = filtersArray[indexPath.section].sectionFilters[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return filtersArray[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = filterTableView.cellForRow(at: indexPath) {
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                print(indexPath.row)
                if indexPath.row == 0 {
                    filterItems.append(1)
                    
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    self.revealViewController().frontViewController.loadView()
                }
                else if indexPath.row == 1 {
                    filterItems.append(2)
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    self.revealViewController().frontViewController.loadView()
                    
                }
                else if indexPath.row == 2 {
                    filterItems.append(3)
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    self.revealViewController().frontViewController.loadView()
                    
                }

            } else {
                cell.accessoryType = .none
                if indexPath.row == 0 {
                    filterItems = filterItems.filter() {$0 != 1}
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    self.revealViewController().frontViewController.loadView()
                }
                else if indexPath.row == 1 {
                     filterItems = filterItems.filter() {$0 != 2}
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    self.revealViewController().frontViewController.loadView()
                }
                else if indexPath.row == 2 {
                    filterItems = filterItems.filter() {$0 != 3}
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    self.revealViewController().frontViewController.loadView()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = filterTableView.cellForRow(at: indexPath)
        cell?.backgroundColor = Colours.codeMobileGrey
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = Colours.darkerCodeMobileGrey
        self.filterTableView.separatorColor = Colours.darkerCodeMobileGrey
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        
        let vc = nav.viewControllers[0] as! ScheduleViewController
        
        vc.filterItems = filterItems
        vc.userIsFiltering = true
        vc.scheduleTableView.reloadData()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        
    }
    
    
    
    
}

// MARK: - Filter TableView Cell UI
class FilterCell : UITableViewCell {
    
    @IBOutlet weak var filterTitleLabel: UILabel!
}
// MARK: - Filter Model
struct Filters {
    
    var sectionName : String!
    var sectionFilters : [String]!
}

struct TagsStruct {
    static var userIsFiltering = false
    static var tagsArray = [Int]()
    static var date = "2017-04-18"
}
