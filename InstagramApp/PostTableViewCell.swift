//
//  PostTableViewCell.swift
//  InstagramApp
//
//  Created by Gwinyai on 17/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userNameTitleButton: UIButton!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var postCommentLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var likesButton: UIButton!
    
    var post: Post?
    
    var postModel: PostModel!
    
    var userModel: UserModel!
        
    var likesModel: LikesModel? {
        didSet {
            guard let likesModel = likesModel else { return }
            setup(likes: likesModel)
            
        }
    }
    
    var currentUserModel: UserModel? {
        didSet {
            guard let currentUser = currentUserModel else { return }
            setup(user: currentUser)
        }
    }
    
    weak var profileDelegate: ProfileDelegate?
    
    weak var feedDelegate: FeedDataDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        profileImage.layer.masksToBounds = true
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        
        likesButton.setImage(UIImage(named: "did_like_icon"), for: .selected)
        likesButton.setImage(UIImage(named: "like_icon"), for: .normal)
    }
    
    func setup(likes: LikesModel?) {
        guard let likes = likes else { return }
        likesCountLabel.text = "\(likes.likesCount)"
        if likes.postDidLike {
            likesButton.isSelected = true
        } else {
            likesButton.isSelected = false
        }
    }
    
    func setup(user: UserModel) {
        userNameTitleButton.setTitle(user.username, for: .normal)
        if let userProfileImage = user.profileImage {
            profileImage.sd_cancelCurrentImageLoad()
            profileImage.sd_setImage(with: userProfileImage, completed: nil)
        }
    }
    
    @IBAction func userNameButtonDidTouch(_ sender: Any) {
        guard let userId = currentUserModel?.userId else { return }
        profileDelegate?.userNameDidTouch(userId: userId)
        
    }
    
    @IBAction func likeButtonDidTouch(_ sender: Any) {
        
        
        
    }
    
    
}
