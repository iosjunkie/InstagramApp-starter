//
//  CommentsModel.swift
//  InstagramApp
//
//  Created by Jules Lee on 20/12/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CommentsModel {
    static var collection: DatabaseReference {
        get {
            return Database.database().reference().child("comments")
        }
    }
    var userId: String?
    var comment: String?
    
    init?(_ snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else { return nil }
        guard let userId = value["user"] as? String else { return nil }
        guard let comment = value["comment"] as? String else { return nil }
        
        self.userId = userId
        self.comment = comment
    }
    
    static func new(comment: String, userId: String, postId: String) {
        guard let key = CommentsModel.collection.child(postId).childByAutoId().key else { return }
        let commentDict: [String: Any] = ["comment": comment, "user": userId]
        CommentsModel.collection.child(postId).updateChildValues(["\(key)": commentDict])
    }
}
