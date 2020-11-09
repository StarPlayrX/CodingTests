//
//  PostMetadataCollectionViewController.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 8/28/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PostMetadataCollectionViewCell"

enum MetadataError: Error {
    case missingData
    case unableToDecodeData
}

class PostMetadataCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var server = Servers.mock
    var downloadTask: URLSessionTask?
    var dataSource = PostMetadataDataSource(ordering: DisplayOrdering(grouping: .none,
                                                                      sorting: .byPublishDate(recentFirst: false)))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(PostMetadataCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        title = "Blog Posts"
        fetchPostMetadata()
    }
    
    // MARK: Actions
    @IBAction func groupByTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Group the posts by...", preferredStyle: .actionSheet)
        
        let groupByAuthorAction = UIAlertAction(title: "Author", style: .default) { [weak self] _ in
            self?.group(by: .author)
        }
        let groupByMonthAction = UIAlertAction(title: "Month", style: .default) { [weak self] _ in
            self?.group(by: .month)
        }
        let noGroupAction = UIAlertAction(title: "No Grouping", style: .default) { [weak self] _ in
            self?.group(by: .none)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(groupByAuthorAction)
        alertController.addAction(groupByMonthAction)
        alertController.addAction(noGroupAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sortTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Sort the posts by...", preferredStyle: .actionSheet)
        
        let sortByAuthorAscendingAction = UIAlertAction(title: "Author from A to Z", style: .default) { [weak self] _ in
            self?.sort(.alphabeticalByAuthor(ascending: true))
        }
        let sortByAuthorDescendingAction = UIAlertAction(title: "Author from Z to A", style: .default) { [weak self] _ in
            self?.sort(.alphabeticalByAuthor(ascending: false))
        }
        let sortByTitleAscendingAction = UIAlertAction(title: "Title from A to Z", style: .default) { [weak self] _ in
            self?.sort(.alphabeticalByTitle(ascending: true))
        }
        let sortByTitleDescendingAction = UIAlertAction(title: "Title from Z to A", style: .default) { [weak self] _ in
            self?.sort(.alphabeticalByTitle(ascending: false))
        }
        let sortByDateAscendingAction = UIAlertAction(title: "Chronologically", style: .default) { [weak self] _ in
            self?.sort(.byPublishDate(recentFirst: false))
        }
        let sortByDateDescendingAction = UIAlertAction(title: "Recent Posts First", style: .default) { [weak self] _ in
            self?.sort(.byPublishDate(recentFirst: true))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(sortByAuthorAscendingAction)
        alertController.addAction(sortByAuthorDescendingAction)
        alertController.addAction(sortByTitleAscendingAction)
        alertController.addAction(sortByTitleDescendingAction)
        alertController.addAction(sortByDateAscendingAction)
        alertController.addAction(sortByDateDescendingAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func group(by grouping: Grouping) {
        dataSource.ordering.grouping = grouping
    }
    
    func sort(_ sorting: Sorting) {
        dataSource.ordering.sorting = sorting
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfPostsInSection(section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostMetadataCollectionViewCell
        
        let postMetadata = dataSource.postMetadata(at: indexPath)
        
        // Configure the cell
        cell.titleLabel.text = postMetadata.title
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postMetadata = dataSource.postMetadata(at: indexPath)

        let url = server.allPostsUrl

        // Get all posts, filter to the selected post, and then show it
        // Is there a better way to do this?
        if downloadTask?.progress.isCancellable ?? false {
            downloadTask?.cancel()
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard error == nil else {
                self?.displayError(error: error!)
                return
            }
            guard let data = data else {
                self?.displayError(error: MetadataError.missingData)
                return
            }
            
            let posts: [Post]?
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                posts = try decoder.decode(Array<Post>.self, from: data)
            } catch {
                self?.displayError(error: error)
                return
            }
            
            let selectedPost = posts?.first { post -> Bool in
                post.id == postMetadata.postId
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let postController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            postController.post = selectedPost
            
            DispatchQueue.main.async {
                self?.navigationController?.pushViewController(postController, animated: true)
            }
        }
        task.resume()
        downloadTask = task
    }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 50)
    }
    
    // MARK: - Data methods
    func fetchPostMetadata() {
        let url = server.allPostMetadataUrl
        
        if downloadTask?.progress.isCancellable ?? false {
            downloadTask?.cancel()
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard error == nil else {
                self?.displayError(error: error!)
                return
            }
            guard let data = data else {
                self?.displayError(error: MetadataError.missingData)
                return
            }
            let metadataList: [PostMetadata]?
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                metadataList = try decoder.decode(Array.self, from: data)
            } catch {
                self?.displayError(error: error)
                return
            }
            
            if let list = metadataList {
                self?.dataSource.postMetadataList = list
            }
            
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
        task.resume()
        downloadTask = task
        
    }
    
    func displayError(error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
