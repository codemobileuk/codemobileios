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
    
    @IBOutlet weak var filterTableView: UITableView!
    
    private let coreData = CoreDataHandler()
    private var filtersArray = [Filters]()
    var filterItems = [Int]()
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filtersArray = [Filters(sectionName:"Days", sectionFilters: ["Tuesday 18th April", "Wednesday 19th April", "Thursday 20th April"]),Filters(sectionName:"Tags", sectionFilters: ["iOS", "Android", "Design", "Security", "Other"]),]
        filterTableView.tableFooterView = UIView()
       recieveCoreData()
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(sortedTags)
        print(sortedSections)
        print(sortedSections[section])
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
        //cell.filterTitleLabel.text = filtersArray[indexPath.section].sectionFilters[indexPath.row]
        cell.filterTitleLabel.text = tableItem.tagTitle
        cell.selectionStyle = .none
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sortedSections[section]
    }
    
    var lastChecked = UITableViewCell()
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = self.filterTableView.indexPathForSelectedRow! as NSIndexPath
        let tableSection = sortedTags[sortedSections[index.section]]
        let tableItem = tableSection![index.row]

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
                else {
                    
                    cell.accessoryType = .none
                   
                }
                
            }
        }
        
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
    
    private var tags: [NSManagedObject] = []
    var sortedSections = ["Days", "Tags"]
    private func recieveCoreData() {
        
        tags = coreData.recieveCoreData(entityNamed: Entities.TAGS)
        sortTags()
    }

    var sortedTags = [String:[TagData]]()
    var completedTags = [String]()
    
    func sortTags() {
        
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
        print(sortedTags)
        filterTableView.reloadData()
        
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

struct TagData {
    
    var tagId = Int()
    var tagTitle = String()
}

struct TagsStruct {
    static var userIsFiltering = false
    static var tagsArray = [Int]()
    static var date = "2017-04-18"
}
