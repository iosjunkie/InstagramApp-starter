//
//  SearchResultsTableViewController.swift
//  InstagramApp
//
//  Created by Jules Lee on 23/12/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SearchResultsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var filteredResults = [UserModel]()
    var shouldShowSearchResults = false
    let tableRefreshControl = UIRefreshControl()
    var navControl = UINavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 10.0, *) {
            tableView.refreshControl = tableRefreshControl
        } else {
            tableView.addSubview(tableRefreshControl)
        }
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        guard var searchQuery = searchController.searchBar.text else { return }
        tableRefreshControl.beginRefreshing()
        if searchQuery == "" {
            shouldShowSearchResults = false
            tableView.separatorStyle = .none
            tableRefreshControl.endRefreshing()
            tableView.reloadData()
            return
        }
        
        searchQuery = searchQuery.lowercased()
        guard let currentUser = Auth.auth().currentUser else { return }
        UserModel.collection.queryOrdered(byChild: "username").queryStarting(atValue: searchQuery).queryEnding(atValue: searchQuery + "\u{f8ff}").queryLimited(toLast: 30).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            var results: [UserModel] = [UserModel]()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let value = child.value as? [String: Any] {
                    if let name = value["username"] as? String {
                        if name.lowercased().contains(searchController.searchBar.text!.lowercased()) {
                            guard let user = UserModel(child) else { continue }
                            if user.userId != currentUser.uid {
                                results.append(user)
                            }
                        }
                    }
                }
            }
            strongSelf.filteredResults = results
            if searchController.searchBar.text != "" {
                strongSelf.shouldShowSearchResults = true
                DispatchQueue.main.async {
                    strongSelf.tableView.separatorStyle = .singleLine
                    strongSelf.tableRefreshControl.endRefreshing()
                    strongSelf.tableView.reloadData()
                }
            }
            else {
                strongSelf.shouldShowSearchResults = false
                DispatchQueue.main.async {
                    strongSelf.tableView.separatorStyle = .none
                    strongSelf.tableRefreshControl.endRefreshing()
                    strongSelf.tableView.reloadData()
                }
            }
        } // absolute necessary for firebase search
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if shouldShowSearchResults {
            return filteredResults.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchresultscell", for: indexPath)

        // Configure the cell...
        
        cell.textLabel?.text = filteredResults[indexPath.row].username
        cell.selectionStyle = .none
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = filteredResults[indexPath.row].userId
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        profileVC.userId = userId
        dismiss(animated: true) {
            self.navControl.pushViewController(profileVC, animated: true)
        }
    }

}
