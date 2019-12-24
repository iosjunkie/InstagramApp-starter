//
//  FeedTableViewCell.swift
//  InstagramApp
//
//  Created by Jules Lee on 13/12/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameTitleButton: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var postCommentLabel: UILabel!
    @IBOutlet weak var commentCountButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    var post: Post?
    weak var feedDelegate: FeedDataDelegate?
    weak var profileDelegate: ProfileDelegate?
    weak var deletePostDelegate: PostDeleteDelegate?
    var postModel: PostModel?
    var likesModel: LikesModel?
    var currentUser: UserModel?
    var userRef: DatabaseReference? {
        willSet {
            resetUser()
        }
        didSet {
            userRef?.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                guard let strongSelf = self else { return }
                if let user = UserModel(snapshot) {
                    strongSelf.currentUser = user
                    DispatchQueue.main.async {
                        strongSelf.setup(user: user)
                    }
                }
            })
        }
    }
    var likesRef: DatabaseReference? {
        willSet {
            resetLikes()
        }
        didSet {
            likesRef?.observeSingleEvent(of: .value, with: { [weak self](snapshot) in
                guard let strongSelf = self else { return }
                strongSelf.likesModel = LikesModel(snapshot)
                strongSelf.setup(likes: strongSelf.likesModel!)
            })
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.masksToBounds = true
        
        selectionStyle = .none
        
        likesButton.setImage(UIImage(named: "did_like_icon"), for: .selected)
        likesButton.setImage(UIImage(named: "like_icon"), for: .normal)
    }
    
    func resetUser() {
        userNameTitleButton.setTitle("--", for: .normal)
        profileImage.image = nil
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
    
    func resetLikes() {
        likesButton.isSelected = false
        likesCountLabel.text = "0"
    }
    
    @IBAction func likeButtonDidTouch(_ sender: UIButton) {
        guard let postModel = postModel else { return }
        guard let likesModel = likesModel else { return }
        
        likesModel.postDidLike = !likesModel.postDidLike
        likesButton.isSelected = likesModel.postDidLike
        if likesModel.postDidLike {
            LikesModel.postLiked(postModel.key)
            likesModel.likesCount += 1
        } else {
            LikesModel.postUnliked(postModel.key)
            if likesModel.likesCount > 0 {
                likesModel.likesCount -= 1
            }
        }
        likesCountLabel.text = "\(likesModel.likesCount)"
    }
    
    @IBAction func viewCommentsButtonDidTouch(_ sender: UIButton) {
        guard let postModel = postModel else { return }
        
        guard let likesModel = likesModel else { return }
        
        guard let userModel = currentUser else { return }
        
        feedDelegate?.commentsDidTouch(post: postModel, likesModel: likesModel, userModel: userModel )
    }
    
    @IBAction func userNameButtonDidTouch(_ sender: UIButton) {
        guard let userId = currentUser?.userId else { return }
        profileDelegate?.userNameDidTouch(userId: userId)
    }
    
    @IBAction func deletePostDidTouch(_ sender: UIButton) {
        guard let postModel = postModel else { return }
        let userPostId = postModel.userId
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        if userPostId == currentUserId {
            deletePostDelegate?.confirmDelete(postId: postModel.key)
        }
    }
}
