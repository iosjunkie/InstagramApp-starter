//
//  ProfileHeaderTableViewCell.swift
//  InstagramApp
//
//  Created by Gwinyai on 20/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    
    @IBOutlet weak var numberOfFollowingLabel: UILabel!
    
    weak var delegate: ProfileHeaderDelegate?
    
    var profileType: ProfileType = .personal
    
    var user: UserModel? {
        didSet {
            guard let userId = user?.userId else { return }
            FollowModel.getFollowersCount(for: userId) { [weak self] (followersCount) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.numberOfFollowersLabel.text = "\(followersCount)"
                }
            }
            FollowModel.getFollowingCount(for: userId) { [weak self] (followingCount) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.numberOfFollowingLabel.text = "\(followingCount)"
                }
            }
            PostModel.getPostCount(for: userId) { [weak self] (postCount) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.numberOfPostsLabel.text = "\(postCount)"
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileButton.layer.borderWidth = CGFloat(0.5)
        
        profileButton.layer.borderColor = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0).cgColor
        
        profileButton.layer.cornerRadius = CGFloat(3.0)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageDidTouch))
        
        profileImageView.addGestureRecognizer(tapRecognizer)
        profileImageView.isUserInteractionEnabled = true
        
        profileImageView.clipsToBounds = true
    }
    
    @objc func profileImageDidTouch() {
        delegate?.profileImageDidTouch()
    }
    
    override func layoutSubviews() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        
    }
    
    @IBAction func profileActionButtonDidTouch(_ sender: Any) {
        
        switch profileType {
            
        case .personal:
            
            logout()
            
        case .otherUser:
            
            follow()
            
        }
        
    }
    
    func logout() {
        
        Helper.logout()
        
    }
    
    func follow() {
        guard let userId = user?.userId else { return }
        FollowModel.toggle(userId) { [weak self] (isFollowing) in
            guard let strongSelf = self else { return }
            guard let isFollowing = isFollowing else { return }
            if isFollowing {
                DispatchQueue.main.async {
                    strongSelf.profileButton.setTitle("Following", for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.profileButton.setTitle("Follow", for: .normal)
                }
            }
        }
        
    }
    
}
