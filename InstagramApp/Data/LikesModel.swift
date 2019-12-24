//
//  LikesModel.swift
//  InstagramApp
//
//  Created by Jules Lee on 19/12/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class LikesModel {
    
    static var collection: DatabaseReference {
        get {
            return Database.database().reference().child("likes")
        }
    }
    var postDidLike: Bool = false
    var likesCount: Int = 0
    
    init?(_ snapshot: DataSnapshot) {
        // guard let value = snapshot.value else { return nil }
        self.likesCount = snapshot.children.allObjects.count
        guard let userId = Auth.auth().currentUser?.uid else { return }
        for item in snapshot.children {
            guard let snapshot = item as? DataSnapshot else { continue }
            if snapshot.key == userId {
                postDidLike = true
                break
            }
            
        }
    }
    
    static func postLiked(_ postKey: String) {
        if let userId = Auth.auth().currentUser?.uid {
            let likesRef = LikesModel.collection.child(postKey)
            likesRef.updateChildValues([userId: true])
        }
        
    }
    
    static func postUnliked(_ postKey: String) {
        if let userId = Auth.auth().currentUser?.uid {
            let likesRef = LikesModel.collection.child(postKey).child(userId)
            likesRef.removeValue()
        }
        
    }
}
