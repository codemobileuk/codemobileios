//
//  FilterViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 08/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    private let coreData = CoreDataHandler()
    private var filterItems = [Int]()
    private var lastChecked = UITableViewCell()
    private var tags: [NSManagedObject] = []
    private let sortedSections = ["Days", "Tags"]
    private var sortedTags = [String:[TagData]]()
    private var completedTags = [String]()
    
    @IBOutlet weak var filterTableView: UITableView!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterTableView.tableFooterView = UIView()
        filterTableView.tableFooterView?.backgroundColor = UIColor.groupTableViewBackground
        recieveCoreData()
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sortedTags.isEmpty == false {
            return sortedTags[sortedSections[section]]!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableSection = sortedTags[sortedSections[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        let cell = self.filterTableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.filterTitleLabel.text = tableItem.tagTitle
        cell.selectionStyle = .none
        cell.backgroundColor = Colours.codeMobileGrey
        
        if TagsStruct.date == "2017-04-18" && cell.filterTitleLabel.text == "Tuesday 18th April"{
            lastChecked.accessoryType = .none
            cell.accessoryType = .checkmark
            lastChecked = cell
        } else if TagsStruct.date == "2017-04-19" && cell.filterTitleLabel.text == "Wednesday 19th April"{
            lastChecked.accessoryType = .none
            cell.accessoryType = .checkmark
            lastChecked = cell
        } else if TagsStruct.date == "2017-04-20" && cell.filterTitleLabel.text == "Thursday 20th April"{
            lastChecked.accessoryType = .none
            cell.accessoryType = .checkmark
            lastChecked = cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sortedSections[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = self.filterTableView.indexPathForSelectedRow! as NSIndexPath
        let tableSection = sortedTags[sortedSections[index.section]]
        let tableItem = tableSection![index.row]
        // Days Section
        if indexPath.section == 0 {
            
            if let cell = filterTableView.cellForRow(at: indexPath) {
                
                if cell.accessoryType == .none {
                    
                    cell.accessoryType = .checkmark
                    lastChecked.accessoryType = .none
                    lastChecked = cell
                    
                    switch (tableItem.tagTitle){
                    case "Tuesday 18th April" :  TagsStruct.date = "2017-04-18"
                    case "Wednesday 19th April" :  TagsStruct.date = "2017-04-19"
                    case "Thursday 20th April" :  TagsStruct.date = "2017-04-20"
                    default : TagsStruct.date = "2017-04-18"
                    }
                    self.revealViewController().frontViewController.loadView()
                    
                }
            }
        }
        // Tags Section
        if indexPath.section == 1 {
            if let cell = filterTableView.cellForRow(at: indexPath) {
                
                if cell.accessoryType == .none {
                    cell.accessoryType = .checkmark
                    filterItems.append(tableItem.tagId)
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    self.revealViewController().frontViewController.loadView()
                }
                else {
                    cell.accessoryType = .none
                    filterItems = filterItems.filter() {$0 != tableItem.tagId}
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
    
    // MARK: - Core Data
    
    private func recieveCoreData() {
        
        tags = coreData.recieveCoreData(entityNamed: Entities.TAGS)
        sortTags()
    }
    
    private func sortTags() {
        
        sortedTags["Days"] = [TagData(tagId: 0, tagTitle: "Tuesday 18th April")]
        sortedTags["Days"]?.append(TagData(tagId: 0, tagTitle: "Wednesday 19th April"))
        sortedTags["Days"]?.append(TagData(tagId: 0, tagTitle: "Thursday 20th April"))
        for item in tags {
            
            if self.sortedTags.index(forKey:"Tags") == nil {
                sortedTags["Tags"] = [TagData(tagId: item.value(forKey: "tagId") as! Int, tagTitle: item.value(forKey: "tag") as! String)]
                completedTags.append(item.value(forKey: "tag") as! String)
            } else {
                if completedTags.contains(item.value(forKey: "tag") as! String) == false {
                    sortedTags["Tags"]?.append(TagData(tagId: item.value(forKey: "tagId") as! Int, tagTitle: item.value(forKey: "tag") as! String))
                    completedTags.append(item.value(forKey: "tag") as! String)
                }
            }
        }
        filterTableView.reloadData()
    }
}

// MARK: - Filter TableViewCell Controller

class FilterCell : UITableViewCell {
    
    @IBOutlet weak var filterTitleLabel: UILabel!
}

// MARK: - Tag Data Model

struct TagData {
    
    var tagId = Int()
    var tagTitle = String()
}

// MARK: - Filtering Model

struct TagsStruct {
    
    static var userIsFiltering = false
    static var tagsArray = [Int]()
    static var date = "2017-04-18"
}
