//
//  ActivityView.swift
//  InstagramApp
//
//  Created by Jules Lee on 16/12/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class ActivityView: UIView, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityTableView: UITableView!
    
    var activityData: [Activity] = [Activity]() {
        didSet {
            activityTableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityTableView.register(UINib(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivityTableViewCell")
        activityTableView.delegate = self
        activityTableView.dataSource = self
        
        activityTableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80.0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell") as! ActivityTableViewCell
        cell.profileImage.image = activityData[indexPath.row].userImage
        cell.detailsLabel.text = activityData[indexPath.row].details
        return cell
    }

}
