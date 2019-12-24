//
//  HomeViewController.swift
//  InstagramApp
//
//  Created by Jules Lee on 13/12/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var posts: NSMutableArray = []
    
    let PAGINATION_COUNT: UInt = 5 // unsigned can't be negative
    
    var newQuery: DatabaseQuery?
    
    var oldRef: DatabaseReference?
    
    var firstChild: DataSnapshot?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = CGFloat(80)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTableViewCell")
        tableView.register(UINib(nibName: "StoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "StoriesTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        var rightBarItemImage = UIImage(named: "send_nav_icon")
        rightBarItemImage = rightBarItemImage?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        var leftBarItemImage = UIImage(named: "camera_nav_icon")
        leftBarItemImage = leftBarItemImage?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarItemImage, style: .plain, target: nil, action: #selector(rightBarButtonItemTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarItemImage, style: .plain, target: nil, action: #selector(newPostButtonDidTouch))
        
        let profileImageView = UIImageView(image: UIImage(named: "logo_nav_icon"))
        self.navigationItem.titleView = profileImageView
        // Do any additional setup after loading the view.
        
        loadData()  
    }
    
    func loadData() {
        let postsRef: DatabaseReference = PostModel.collection
        let postsQuery = postsRef.queryOrderedByKey().queryLimited(toLast: UInt(PAGINATION_COUNT))
        
        postsQuery.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            for item in snapshot.children {
                guard let snapshot = item as? DataSnapshot else { continue }
                guard let post = PostModel(snapshot) else { continue }
                strongSelf.posts.insert(post, at: 0)
            }
            strongSelf.firstChild = snapshot.children.allObjects.first as? DataSnapshot
            let lastChild = snapshot.children.allObjects.last as? DataSnapshot
            strongSelf.observeNewItems(lastChild, newRef: postsRef)
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        }
        oldRef?.removeAllObservers()
        oldRef = postsRef
        oldRef?.observe(.childRemoved, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            for item in strongSelf.posts {
                if let post = item as? PostModel, snapshot.key == post.key {
                    strongSelf.posts.remove(item)
                }
            }
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        })
    }
    
    func observeNewItems(_ lastChild: DataSnapshot?, newRef: DatabaseReference) {
        newQuery?.removeAllObservers()
        newQuery = newRef.queryOrderedByKey()
        if let startKey = lastChild?.key {
            newQuery?.queryStarting(atValue: startKey)
        }
        
        newQuery?.observe(.childAdded, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            if snapshot.key != lastChild?.key {
                if let post = PostModel(snapshot) {
                    strongSelf.posts.insert(post, at: 0)
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    func loadMore() {
        let postsRef: DatabaseReference = PostModel.collection
        var paginationQuery = postsRef.queryOrderedByKey().queryLimited(toLast: PAGINATION_COUNT + 1)
        if let firstKey = firstChild?.key {
            paginationQuery = paginationQuery.queryEnding(atValue: firstKey)
            paginationQuery.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                guard let strongSelf = self else { return }
                let items = snapshot.children.allObjects
                var indexes: [IndexPath] = []
                if items.count > 1 {
                    for _ in 2...items.count {
                        _ = items[items.count - 1] as! DataSnapshot
                        indexes.append(IndexPath(row: strongSelf.posts.count, section: 0))
                        if let post = PostModel(snapshot) {
                            strongSelf.posts.add(post)
                        }
                    }
                    strongSelf.firstChild = snapshot.children.allObjects.first as? DataSnapshot
                    DispatchQueue.main.async {
                        strongSelf.tableView.insertRows(at: indexes, with: .fade)
                    }
                }
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let lastIndex = self.tableView.indexPathsForVisibleRows?.last {
            if lastIndex.row >= self.posts.count - 2 {
                loadMore()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesTableViewCell") as! StoriesTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        let currendIndex = indexPath.row - 1
        let post = posts[currendIndex] as! PostModel
        cell.postImage.sd_cancelCurrentImageLoad()
        cell.postImage.sd_setImage(with: post.imageURL, completed: nil)
        cell.postCommentLabel.text = post.caption
        cell.postImage.backgroundColor = .lightGray
        cell.userRef = UserModel.collection.child(post.userId!)
        cell.likesRef = LikesModel.collection.child(post.key)
        cell.postModel = post
        cell.deletePostDelegate = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy hh:mm"
        cell.dateLabel.text = dateFormatter.string(from: post.date!)
        cell.feedDelegate = self
        
//        if postData.comments.count > 0 {
//
//            let commentTitle = postData.comments.count == 1 ? "View 1 comment" : "View all \(postData.comments.count) comments"
//
//            cell.commentCountButton.setTitle(commentTitle, for: .normal)
//
//            cell.commentCountButton.isEnabled = true
//
//        }
//        else {
//
//            cell.commentCountButton.setTitle("0 comments", for: .normal)
//
//            cell.commentCountButton.isEnabled = false
//
//        }
        
        cell.feedDelegate = self
        
        cell.profileDelegate = self
        
        cell.postModel = post
        
        return cell
    }
    
    @objc func rightBarButtonItemTapped() {
        
    }
    
    @objc func leftBarButtonItemTapped() {
        
    }
    
    @objc func newPostButtonDidTouch() {
        
        let newPostStoryboard = UIStoryboard(name: "NewPost", bundle: nil)
        
        let newPostVC = newPostStoryboard.instantiateViewController(withIdentifier: "NewPost") as! NewPostViewController
        
        let navController = UINavigationController(rootViewController: newPostVC)
        
        present(navController, animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        newQuery?.removeAllObservers()
        oldRef?.removeAllObservers()
    }

}

extension HomeViewController: FeedDataDelegate {
    
    func commentsDidTouch(post: PostModel, likesModel: LikesModel, userModel: UserModel) {
        
        let postStoryboard = UIStoryboard(name: "Post", bundle: nil)
        
        let postVC = postStoryboard.instantiateViewController(withIdentifier: "Post") as! PostViewController
        
        postVC.postModel = post
        
        postVC.likesModel = likesModel
        
        postVC.userModel = userModel
        
        navigationController?.pushViewController(postVC, animated: true)
        
    }
    
}

extension HomeViewController: ProfileDelegate {
    
    func userNameDidTouch(userId: String) {
        
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        
        let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        profileVC.userId = userId
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
}

extension HomeViewController: PostDeleteDelegate {
    func confirmDelete(postId: String) {
        let alert = UIAlertController(title: "Delete Post", message: "Are you sure you would like to delete this post?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            PostModel.deletePost(id: postId)
            alert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
