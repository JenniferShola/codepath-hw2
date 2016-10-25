//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchResultsUpdating, UISearchDisplayDelegate, UIScrollViewDelegate {
    
    let default_term = "Restaurants"
    var businesses: [Business]!
    var isMoreDataLoading = false
    var searchController: UISearchController!
    
    var categories: [String]? = []
    var deals: Bool? = false
    var sort_by: YelpSortMode? = YelpSortMode.bestMatched
    var distance: Int? = 25000
    var term: String? = "Restaurants"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = default_term
        
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true

        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height + 20
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                Business.searchWithTerm(term: default_term, sort: sort_by, categories: categories, deals: deals, distance: distance, offset: self.businesses.count, completion: { (businesses: [Business]?, error: Error?) -> Void in
                    if let busis = businesses {
                        for biz in busis {
                            self.businesses.append(biz)
                        }
                        self.isMoreDataLoading = false
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if !searchText.isEmpty {
                term = searchText
                Business.searchWithTerm(term: "\(default_term) \(searchText)", completion: { (businesses: [Business]?, error: Error?) -> Void in
                    self.businesses = businesses
                    self.tableView.reloadData()
                    self.searchController.loadView()
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        self.categories = filters["categories"] as? [String]
        self.deals = filters["deals"] as? Bool
        self.sort_by = filters["sort"] as? YelpSortMode
        self.distance = filters["distance"] as? Int
        Business.searchWithTerm(term: default_term, sort: sort_by, categories: categories, deals: deals, distance: distance, offset: nil, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    
}
