//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Shola Oyedele on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories: [[String:String]]!
    var categorySwitchStates = [Int:Bool]()
    var distancesSwitchStates = [Int:Bool]()
    var hiddenDistanceStates = [Int:Bool]()
    var sortSwitchStates = [Int:Bool]()
    var hiddenSortStates = [Int:Bool]()
    var switchStates = [Int:Bool]()
    var dealSwitchState = false
    
    var lastRow = 0
    var lastSection = 0
    
    let deals_section = 0
    let distance_section = 1
    let sort_section = 2
    let category_section = 3
    
    let section_headers = ["Deals", "Distance", "Sort By", "Categories"]
    let deals_data = ["Offering a Deal"]
    let distance_data = [25000, 300, 1000, 5000, 20000]
    let sort_data = ["Best Match", "Higest Rated"]
    
    var data = [("Deals", [["name" : "Offering a Deal"]]),
                ("Distance", [["name" : "Auto"], ["name" : "0.3 miles"], ["name" : "1 mile"], ["name" : "5 miles"], ["name" : "20 miles"]]),
                ("Sort By", [["name" : "Best Match"], ["name" : "Higest Rated"]])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        categories = yelpCategories()
        data.append(("Categories", categories))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: AnyObject) {
        var filters = [String: AnyObject]()
        var selectedCategories = [String]()
        for (row, isSelected) in categorySwitchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }
        
        for sort in sortSwitchStates {
            if sort.value == true {
                if sort.key == 1 {
                    filters["sort"] = YelpSortMode.bestMatched as AnyObject
                } else if sort.key == 2 {
                    filters["sort"] = YelpSortMode.highestRated as AnyObject
                } else {
                    filters["sort"] = nil
                }
            }
        }
        
        if dealSwitchState {
            filters["deals"] = true as AnyObject
        } else {
            filters["deals"] = false as AnyObject
        }
        
        for distance in distancesSwitchStates {
            if distance.value == true {
                filters["distance"] = distance_data[distance.key] as AnyObject
            }
        }
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        
        let animation = lastRow == indexPath.row && lastSection == indexPath.section
        
        let filter = data[indexPath.section].1[indexPath.row]
        cell.switchLabel.text = "\(filter["name"]!)"
        cell.delegate = self
        
        if indexPath.section == deals_section {
            cell.flipSwitch.setSelected(dealSwitchState, animated: animation)
        } else if indexPath.section == distance_section {
            let state = distancesSwitchStates[indexPath.row] ?? false
            if let hidden = hiddenDistanceStates[indexPath.row] {
                cell.flipSwitch.isHidden = hidden
                cell.flipSwitch.setSelected(state, animated: animation)
            } else {
                cell.flipSwitch.isHidden = false
                cell.flipSwitch.setSelected(state, animated: animation)
            }
        } else if indexPath.section == sort_section {
            let state = sortSwitchStates[indexPath.row] ?? false
            if let hidden = hiddenSortStates[indexPath.row] {
                cell.flipSwitch.isHidden = hidden
                cell.flipSwitch.setSelected(state, animated: animation)
            } else {
                cell.flipSwitch.isHidden = false
                cell.flipSwitch.setSelected(state, animated: animation)
            }
        } else if indexPath.section == category_section {
            let state = categorySwitchStates[indexPath.row] ?? false
            cell.flipSwitch.setSelected(state, animated: animation)
        }
        
        if animation {
            lastRow = -1
            lastSection = -1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section_headers[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return section_headers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == deals_section {
            return deals_data.count
        } else if section == distance_section {
            return distance_data.count
        } else if section == sort_section {
            return sort_data.count
        } else if section == category_section {
            return categories.count
        }
        return 0
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)
        if indexPath?.section == deals_section {
            dealSwitchState = value
        } else if indexPath?.section == distance_section {
            if value == true {
                for row in (0...distance_data.count) {
                    if row != indexPath!.row {
                        hiddenDistanceStates[row] = true
                    }
                }
            } else {
                for row in (0...distance_data.count) {
                    if row != indexPath!.row {
                        hiddenDistanceStates[row] = false
                    }
                }
            }
            distancesSwitchStates[indexPath!.row] = value
        } else if indexPath?.section == sort_section {
            if value == true {
                for row in (0...sort_data.count) {
                    if row != indexPath!.row {
                        hiddenSortStates[row] = true
                    }
                }
            } else {
                for row in (0...sort_data.count) {
                    if row != indexPath!.row {
                        hiddenSortStates[row] = false
                    }
                }
            }
            sortSwitchStates[indexPath!.row] = value
        } else if indexPath?.section == category_section {
            categorySwitchStates[indexPath!.row] = value
        }
        lastRow = indexPath?.row ?? -1
        lastSection = indexPath?.section ?? -1
        tableView.reloadData()
        
    }
    
    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
                                  ["name" : "African", "code": "african"],
                                  ["name" : "American, New", "code": "newamerican"],
                                  ["name" : "American, Traditional", "code": "tradamerican"],
                                  ["name" : "Arabian", "code": "arabian"],
                                  ["name" : "Argentine", "code": "argentine"],
                                  ["name" : "Armenian", "code": "armenian"],
                                  ["name" : "Asian Fusion", "code": "asianfusion"],
                                  ["name" : "Asturian", "code": "asturian"],
                                  ["name" : "Australian", "code": "australian"],
                                  ["name" : "Austrian", "code": "austrian"],
                                  ["name" : "Baguettes", "code": "baguettes"],
                                  ["name" : "Bangladeshi", "code": "bangladeshi"],
                                  ["name" : "Barbeque", "code": "bbq"],
                                  ["name" : "Basque", "code": "basque"],
                                  ["name" : "Bavarian", "code": "bavarian"],
                                  ["name" : "Beer Garden", "code": "beergarden"],
                                  ["name" : "Beer Hall", "code": "beerhall"],
                                  ["name" : "Beisl", "code": "beisl"],
                                  ["name" : "Belgian", "code": "belgian"],
                                  ["name" : "Bistros", "code": "bistros"],
                                  ["name" : "Black Sea", "code": "blacksea"],
                                  ["name" : "Brasseries", "code": "brasseries"],
                                  ["name" : "Brazilian", "code": "brazilian"],
                                  ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                                  ["name" : "British", "code": "british"],
                                  ["name" : "Buffets", "code": "buffets"],
                                  ["name" : "Bulgarian", "code": "bulgarian"],
                                  ["name" : "Burgers", "code": "burgers"],
                                  ["name" : "Burmese", "code": "burmese"],
                                  ["name" : "Cafes", "code": "cafes"],
                                  ["name" : "Cafeteria", "code": "cafeteria"],
                                  ["name" : "Cajun/Creole", "code": "cajun"],
                                  ["name" : "Cambodian", "code": "cambodian"],
                                  ["name" : "Canadian", "code": "New)"],
                                  ["name" : "Canteen", "code": "canteen"],
                                  ["name" : "Caribbean", "code": "caribbean"],
                                  ["name" : "Catalan", "code": "catalan"],
                                  ["name" : "Chech", "code": "chech"],
                                  ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                                  ["name" : "Chicken Shop", "code": "chickenshop"],
                                  ["name" : "Chicken Wings", "code": "chicken_wings"],
                                  ["name" : "Chilean", "code": "chilean"],
                                  ["name" : "Chinese", "code": "chinese"],
                                  ["name" : "Comfort Food", "code": "comfortfood"],
                                  ["name" : "Corsican", "code": "corsican"],
                                  ["name" : "Creperies", "code": "creperies"],
                                  ["name" : "Cuban", "code": "cuban"],
                                  ["name" : "Curry Sausage", "code": "currysausage"],
                                  ["name" : "Cypriot", "code": "cypriot"],
                                  ["name" : "Czech", "code": "czech"],
                                  ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                                  ["name" : "Danish", "code": "danish"],
                                  ["name" : "Delis", "code": "delis"],
                                  ["name" : "Diners", "code": "diners"],
                                  ["name" : "Dumplings", "code": "dumplings"],
                                  ["name" : "Eastern European", "code": "eastern_european"],
                                  ["name" : "Ethiopian", "code": "ethiopian"],
                                  ["name" : "Fast Food", "code": "hotdogs"],
                                  ["name" : "Filipino", "code": "filipino"],
                                  ["name" : "Fish & Chips", "code": "fishnchips"],
                                  ["name" : "Fondue", "code": "fondue"],
                                  ["name" : "Food Court", "code": "food_court"],
                                  ["name" : "Food Stands", "code": "foodstands"],
                                  ["name" : "French", "code": "french"],
                                  ["name" : "French Southwest", "code": "sud_ouest"],
                                  ["name" : "Galician", "code": "galician"],
                                  ["name" : "Gastropubs", "code": "gastropubs"],
                                  ["name" : "Georgian", "code": "georgian"],
                                  ["name" : "German", "code": "german"],
                                  ["name" : "Giblets", "code": "giblets"],
                                  ["name" : "Gluten-Free", "code": "gluten_free"],
                                  ["name" : "Greek", "code": "greek"],
                                  ["name" : "Halal", "code": "halal"],
                                  ["name" : "Hawaiian", "code": "hawaiian"],
                                  ["name" : "Heuriger", "code": "heuriger"],
                                  ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                                  ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                                  ["name" : "Hot Dogs", "code": "hotdog"],
                                  ["name" : "Hot Pot", "code": "hotpot"],
                                  ["name" : "Hungarian", "code": "hungarian"],
                                  ["name" : "Iberian", "code": "iberian"],
                                  ["name" : "Indian", "code": "indpak"],
                                  ["name" : "Indonesian", "code": "indonesian"],
                                  ["name" : "International", "code": "international"],
                                  ["name" : "Irish", "code": "irish"],
                                  ["name" : "Island Pub", "code": "island_pub"],
                                  ["name" : "Israeli", "code": "israeli"],
                                  ["name" : "Italian", "code": "italian"],
                                  ["name" : "Japanese", "code": "japanese"],
                                  ["name" : "Jewish", "code": "jewish"],
                                  ["name" : "Kebab", "code": "kebab"],
                                  ["name" : "Korean", "code": "korean"],
                                  ["name" : "Kosher", "code": "kosher"],
                                  ["name" : "Kurdish", "code": "kurdish"],
                                  ["name" : "Laos", "code": "laos"],
                                  ["name" : "Laotian", "code": "laotian"],
                                  ["name" : "Latin American", "code": "latin"],
                                  ["name" : "Live/Raw Food", "code": "raw_food"],
                                  ["name" : "Lyonnais", "code": "lyonnais"],
                                  ["name" : "Malaysian", "code": "malaysian"],
                                  ["name" : "Meatballs", "code": "meatballs"],
                                  ["name" : "Mediterranean", "code": "mediterranean"],
                                  ["name" : "Mexican", "code": "mexican"],
                                  ["name" : "Middle Eastern", "code": "mideastern"],
                                  ["name" : "Milk Bars", "code": "milkbars"],
                                  ["name" : "Modern Australian", "code": "modern_australian"],
                                  ["name" : "Modern European", "code": "modern_european"],
                                  ["name" : "Mongolian", "code": "mongolian"],
                                  ["name" : "Moroccan", "code": "moroccan"],
                                  ["name" : "New Zealand", "code": "newzealand"],
                                  ["name" : "Night Food", "code": "nightfood"],
                                  ["name" : "Norcinerie", "code": "norcinerie"],
                                  ["name" : "Open Sandwiches", "code": "opensandwiches"],
                                  ["name" : "Oriental", "code": "oriental"],
                                  ["name" : "Pakistani", "code": "pakistani"],
                                  ["name" : "Parent Cafes", "code": "eltern_cafes"],
                                  ["name" : "Parma", "code": "parma"],
                                  ["name" : "Persian/Iranian", "code": "persian"],
                                  ["name" : "Peruvian", "code": "peruvian"],
                                  ["name" : "Pita", "code": "pita"],
                                  ["name" : "Pizza", "code": "pizza"],
                                  ["name" : "Polish", "code": "polish"],
                                  ["name" : "Portuguese", "code": "portuguese"],
                                  ["name" : "Potatoes", "code": "potatoes"],
                                  ["name" : "Poutineries", "code": "poutineries"],
                                  ["name" : "Pub Food", "code": "pubfood"],
                                  ["name" : "Rice", "code": "riceshop"],
                                  ["name" : "Romanian", "code": "romanian"],
                                  ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                                  ["name" : "Rumanian", "code": "rumanian"],
                                  ["name" : "Russian", "code": "russian"],
                                  ["name" : "Salad", "code": "salad"],
                                  ["name" : "Sandwiches", "code": "sandwiches"],
                                  ["name" : "Scandinavian", "code": "scandinavian"],
                                  ["name" : "Scottish", "code": "scottish"],
                                  ["name" : "Seafood", "code": "seafood"],
                                  ["name" : "Serbo Croatian", "code": "serbocroatian"],
                                  ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                                  ["name" : "Singaporean", "code": "singaporean"],
                                  ["name" : "Slovakian", "code": "slovakian"],
                                  ["name" : "Soul Food", "code": "soulfood"],
                                  ["name" : "Soup", "code": "soup"],
                                  ["name" : "Southern", "code": "southern"],
                                  ["name" : "Spanish", "code": "spanish"],
                                  ["name" : "Steakhouses", "code": "steak"],
                                  ["name" : "Sushi Bars", "code": "sushi"],
                                  ["name" : "Swabian", "code": "swabian"],
                                  ["name" : "Swedish", "code": "swedish"],
                                  ["name" : "Swiss Food", "code": "swissfood"],
                                  ["name" : "Tabernas", "code": "tabernas"],
                                  ["name" : "Taiwanese", "code": "taiwanese"],
                                  ["name" : "Tapas Bars", "code": "tapas"],
                                  ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                                  ["name" : "Tex-Mex", "code": "tex-mex"],
                                  ["name" : "Thai", "code": "thai"],
                                  ["name" : "Traditional Norwegian", "code": "norwegian"],
                                  ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                                  ["name" : "Trattorie", "code": "trattorie"],
                                  ["name" : "Turkish", "code": "turkish"],
                                  ["name" : "Ukrainian", "code": "ukrainian"],
                                  ["name" : "Uzbek", "code": "uzbek"],
                                  ["name" : "Vegan", "code": "vegan"],
                                  ["name" : "Vegetarian", "code": "vegetarian"],
                                  ["name" : "Venison", "code": "venison"],
                                  ["name" : "Vietnamese", "code": "vietnamese"],
                                  ["name" : "Wok", "code": "wok"],
                                  ["name" : "Wraps", "code": "wraps"],
                                  ["name" : "Yugoslav", "code": "yugoslav"]]
    }
}
