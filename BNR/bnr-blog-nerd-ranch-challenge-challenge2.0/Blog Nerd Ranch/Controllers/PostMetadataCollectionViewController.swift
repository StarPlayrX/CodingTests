//
//  PostMetadataCollectionViewController.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 8/28/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

private let PMD_reuseIdentifier = "PostMetadataCollectionViewCell"
private var orgMetaDataList = [PostMetadata]()
private var groupDataList = [PostMetadata]()

enum MetadataError: Error {
    case missingData
    case unableToDecodeData
}

class PostMetadataCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var server = Servers.mock
    var downloadTask: URLSessionTask?
    var dataSource = PostMetadataDataSource(ordering: DisplayOrdering(grouping: .author,
                                                                      sorting: .byPublishDate(recentFirst: false)))
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes and Xcode Interface Builder Files
        let cellXib = UINib(nibName: PMD_reuseIdentifier, bundle: nil)
        self.collectionView.register(cellXib, forCellWithReuseIdentifier: PMD_reuseIdentifier)

        // Do any additional setup after loading the view.
        title = "Blog Posts"
        fetchPostMetadata()
    }
    
    //MARK: No Grouping
    func noGrouping() {
        dataSource.postMetadataList = orgMetaDataList
        refreshScreen()
    }
    
    //MARK: Group By Month
    func groupByArtist(weighted: Bool) {
        
        groupDataList = [PostMetadata]()

        var artistDictionary = [String: [PostMetadata] ]()
        
        for a in orgMetaDataList {
            let artist = a.author.name
            if let _ = artistDictionary.index(forKey: artist) {
                artistDictionary[a.author.name]?.append(a)
            } else {
                artistDictionary[a.author.name] = [PostMetadata]()
                artistDictionary[a.author.name]?.append(a)
            }
        }
        
        var artistGroup = artistDictionary.sorted() {$0.key.count < $1.key.count}
        
        weighted ? artistGroup.sort() {$0.value.count > $1.value.count} : artistGroup.sort() {$0.value.count > $1.value.count}

        for b in artistGroup {
            if !b.value.isEmpty {
                groupDataList.append(contentsOf: b.value)
            }
        }
        
        dataSource.postMetadataList = groupDataList
        refreshScreen()
    }
    
    //MARK: Group By Month
    func groupByMonth(weighted: Bool) {
        
        /* The focus here is to refrain from a nested loop that would lead to 12x processing time and would not scale */
        
        //MARK: Step 1 : clear month day list
        groupDataList = [PostMetadata]()
        
        let group = [PostMetadata]()
        var groups = Array<[PostMetadata]>()
            
        //MARK: Step 2 : create 1 empty group for each month
        for _ in 1...12 {
            groups.append(group)
        }
            
        //MARK: Step 3 : group like months together within each "month" array (divvy up the main metadata list, Big O(n) )
        for obj in orgMetaDataList {
            let cal = Calendar.current
            let month = Int(cal.component(.month, from: obj.publishDate))
            groups[ month - 1 ].append(obj)
        }
            
        //MARK: Step 4 : If weighted, make the group weighted (This puts the larger groups first.)
        weighted ? groups.sort() {$0.count > $1.count} : groups.sort() {$0.count < $1.count}
        
        //MARK: Step 5 : Create the final grouped month list
        for i in 0...11 {
            if !groups[i].isEmpty {
                groupDataList.append(contentsOf:groups[i])
            }
        }
        
        //MARK step 6 : update the UI
        dataSource.postMetadataList = groupDataList
        refreshScreen()
    }


    // MARK: Actions
    @IBAction func groupByTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Group the posts by...", preferredStyle: .actionSheet)
          
        
        let groupByAuthorAction = UIAlertAction(title: "Author", style: .default) { [weak self] _ in
            self?.group(by: .author)
            self?.groupByArtist(weighted: true)
        }
        let groupByMonthAction = UIAlertAction(title: "Month", style: .default) { [weak self] _ in
            self?.group(by: .month)
            self?.groupByMonth(weighted: true)
        }
        let noGroupAction = UIAlertAction(title: "No Grouping", style: .default) { [weak self] _ in
            self?.group(by: .none)
            self?.noGrouping()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(groupByAuthorAction)
        alertController.addAction(groupByMonthAction)
        alertController.addAction(noGroupAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //Updates the screen
    func refreshScreen() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
   
    
    //MARK: Helper Methods for sorting
    func sortListByTitle(ascending: Bool) {
        ascending ? dataSource.postMetadataList.sort() { $0.title < $1.title } :
                    dataSource.postMetadataList.sort() { $0.title > $1.title }
        refreshScreen()
    }
    
    func sortListByAuthor(ascending: Bool) {
        ascending ? dataSource.postMetadataList.sort() { $0.author.name < $1.author.name } :
                    dataSource.postMetadataList.sort() { $0.author.name > $1.author.name }
        refreshScreen()
    }
    
    func sortListByPosts(ascending: Bool) {
        ascending ? dataSource.postMetadataList.sort() { $0.publishDate > $1.publishDate } :
                    dataSource.postMetadataList.sort() { $0.publishDate < $1.publishDate }
        refreshScreen()
    }

    
    @IBAction func sortTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Sort the posts by...", preferredStyle: .actionSheet)
        
        let sortByAuthorascendingAction = UIAlertAction(title: "Author from A to Z", style: .default) { [weak self] _ in
            self?.sort(.alphabeticalByAuthor(ascending: true))
            self?.sortListByAuthor(ascending: true)
        }
        let sortByAuthorDescendingAction = UIAlertAction(title: "Author from Z to A", style: .default) { [weak self] _ in
            self?.sort(.alphabeticalByAuthor(ascending: false))
            self?.sortListByAuthor(ascending: false)
        }
        let sortByTitleascendingAction = UIAlertAction(title: "Title from A to Z", style: .default) { [weak self] _ in
            self?.sort(.alphabeticalByTitle(ascending: true))
            self?.sortListByTitle(ascending: true)
        }
        let sortByTitleDescendingAction = UIAlertAction(title: "Title from Z to A", style: .default) { [weak self] _ in
            self?.sort(.alphabeticalByTitle(ascending: false))
            self?.sortListByTitle(ascending: false)
        }
        let sortByDateascendingAction = UIAlertAction(title: "Chronologically", style: .default) { [weak self] _ in
            self?.sort(.byPublishDate(recentFirst: false))
            self?.sortListByPosts(ascending: false)
        }
        let sortByDateDescendingAction = UIAlertAction(title: "Recent Posts First", style: .default) { [weak self] _ in
            self?.sort(.byPublishDate(recentFirst: true))
            self?.sortListByPosts(ascending: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(sortByAuthorascendingAction)
        alertController.addAction(sortByAuthorDescendingAction)
        alertController.addAction(sortByTitleascendingAction)
        alertController.addAction(sortByTitleDescendingAction)
        alertController.addAction(sortByDateascendingAction)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PMD_reuseIdentifier, for: indexPath) as! PostMetadataCollectionViewCell
        
        let postMetadata = dataSource.postMetadata(at: indexPath)
      
        //Cell data
        cell.titleLabel.text = postMetadata.title
        cell.authorLabel.text = postMetadata.author.name
        cell.summaryLabel.text = postMetadata.summary
        
        //Format the Date to a human readable
        let formatDate = DateFormatter()
        formatDate.dateFormat = "yyyy-MM-dd"
        let formatDateString = formatDate.string(from: postMetadata.publishDate)
        
        cell.publishDateLabel.text = formatDateString
        
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
        return UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 8)
    }
    
    //MARK: full width cells that fit any size screen
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 125)
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
                orgMetaDataList = list
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
