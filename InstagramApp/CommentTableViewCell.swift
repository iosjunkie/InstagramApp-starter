//
//  CommentTableViewCell.swift
//  InstagramApp
//
//  Created by Gwinyai on 17/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel!
    var currentUserModel: UserModel?
    var commentIndex: Int?
    var userRef: DatabaseReference? {
        willSet {
            userNameLabel.text = "--"
        }
        
        didSet {
            userRef?.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                guard let strongSelf = self else { return }
                
                DispatchQueue.main.async {
                    if let user = UserModel(snapshot) {
                        strongSelf.currentUserModel = user
                        strongSelf.userNameLabel.text = user.username
                    }
                }
                
            })
        }
    }

    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //commentLabel.delegate = self
        
        selectionStyle = .none
        
    }
    
}


