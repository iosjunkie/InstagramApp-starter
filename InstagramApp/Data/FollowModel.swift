//
//  FollowModel.swift
//  InstagramApp
//
//  Created by Jules Lee on 12/24/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class FollowModel {
    static var followingCollection = Database.database().reference().child("following")
    static var followersCollection = Database.database().reference().child("followers")
    
    static func getFollowingCount(for userId: String, completion: @escaping(_ success: Int) -> Void) {
        let followingRef = FollowModel.followingCollection.child(userId)
        followingRef.observeSingleEvent(of: .value) { (snapshot) in
            let followingCount = Int(snapshot.childrenCount)
            completion(followingCount)
            return
        }
    }
    
    static func getFollowersCount(for userId: String, completion: @escaping(_ followersCount: Int) -> Void) {
        let followingRef = FollowModel.followersCollection.child(userId)
        followingRef.observeSingleEvent(of: .value) { (snapshot) in
            let followingCount = Int(snapshot.childrenCount)
            completion(followingCount)
            return
        }
    }
    
    static func toggle(_ followUserId: String, completion: @escaping(_ isFollowing: Bool?) -> Void) {
        guard let currentId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        if followUserId == currentId {
            completion(nil)
            return
        }
        let followingRef = FollowModel.followingCollection.child(currentId)
        let followersRef = FollowModel.followersCollection.child(followUserId)
        followingRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(followUserId) {
                followingRef.child(followUserId).removeValue()
                followersRef.child(currentId).removeValue()
                
                completion(false)
            } else {
                followingRef.child(followUserId).setValue(true)
                followersRef.child(currentId).setValue(true)
                completionn(true)
            }
        }
    }
}
