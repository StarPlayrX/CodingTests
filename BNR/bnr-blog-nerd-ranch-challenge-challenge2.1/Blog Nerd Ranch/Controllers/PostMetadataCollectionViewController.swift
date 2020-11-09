//
//  PostMetadataCollectionViewController.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 8/28/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

private let PMD_reuseIdentifier = "PostMetadataCollectionViewCell"
private let HDR_reuseIdentifier = "HeaderCollectionViewCell"

enum MetadataError: Error {
    case missingData
    case unableToDecodeData
}

class PostMetadataCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var server = Servers.mock
    var downloadTask: URLSessionTask?
    var dataSource = PostMetadataDataSource(ordering: DisplayOrdering(grouping: .author, sorting: .byPublishDate(recentFirst: false)))
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes and Xcode Interface Builder Files
        let cellXib = UINib(nibName: PMD_reuseIdentifier, bundle: nil)
        self.collectionView.register(cellXib, forCellWithReuseIdentifier: PMD_reuseIdentifier)
        
        let cellXib_HDR = UINib(nibName: HDR_reuseIdentifier, bundle: nil)
        self.collectionView.register(cellXib_HDR, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCollectionViewCell")
        
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
            displayTitle = "BNR"
            self?.group(by: .none)
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
    
    @IBAction func sortTapped(_ sender: UIBarButtonItem) {
        
        let authorsAtoZ = "Authors from A to Z"
        let authorsZtoA = "Authors from Z to A"
        let titlesAtoZ = "Titles from A to Z"
        let titlesZtoA = "Titles from Z to A"
        let chronologically = "Chronologically"
        let recentPosts = "Recent Posts"

        let alertController = UIAlertController(title: nil, message: "Sort the posts by...", preferredStyle: .actionSheet)
        
        let sortByAuthorascendingAction = UIAlertAction(title: authorsAtoZ, style: .default) { [weak self] _ in
            displayTitle = authorsAtoZ
            self?.sort(.alphabeticalByAuthor(ascending: true))
        }
        
        let sortByAuthorDescendingAction = UIAlertAction(title: authorsZtoA, style: .default) { [weak self] _ in
            displayTitle = authorsZtoA
            self?.sort(.alphabeticalByAuthor(ascending: false))
        }
        
        let sortByTitleascendingAction = UIAlertAction(title: titlesAtoZ, style: .default) { [weak self] _ in
            displayTitle = titlesAtoZ
            self?.sort(.alphabeticalByTitle(ascending: true))
        }
        
        let sortByTitleDescendingAction = UIAlertAction(title: titlesZtoA, style: .default) { [weak self] _ in
            displayTitle = titlesZtoA
            self?.sort(.alphabeticalByTitle(ascending: false))
        }
        
        let sortByDateascendingAction = UIAlertAction(title: chronologically, style: .default) { [weak self] _ in
            displayTitle = chronologically
            self?.sort(.byPublishDate(recentFirst: false))
        }
        
        let sortByDateDescendingAction = UIAlertAction(title: "\(recentPosts) First", style: .default) { [weak self] _ in
            displayTitle = recentPosts
            self?.sort(.byPublishDate(recentFirst: true))
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
    
    
    //MARK: Group algorthims
    func group(by grouping: Grouping) {
        dataSource.ordering.grouping = grouping
        
        switch dataSource.ordering.grouping {
        case Grouping.author : dataSource.groupByauthor(weighted: false)
        case Grouping.month  : dataSource.groupByMonthAndYear(weighted: false)
        case Grouping.none   : dataSource.noGrouping()
        }
        
        refreshScreen()
        
    }
    
    
    //MARK: Sorting algorthims
    func sort(_ sorting: Sorting) {
        
        dataSource.ordering.sorting = sorting
        switch dataSource.ordering.sorting {
        case .alphabeticalByAuthor(ascending: let ascending) : dataSource.sortListByAuthor(ascending: ascending)
        case .alphabeticalByTitle(ascending: let ascending)  : dataSource.sortListByTitle(ascending: ascending)
        case .byPublishDate(recentFirst: let recentFirst)    : dataSource.sortListByPosts(ascending: recentFirst)
        }
        
        refreshScreen()
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfPostsInSection(section)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HDR_reuseIdentifier, for: indexPath) as! HeaderCollectionViewCell
            
            sectionHeader.label.text = dataSource.titleForSection(indexPath.section)
            sectionHeader.backgroundColor = .lightGray
            return sectionHeader
        } else { //No footer in this case but can add option for that
            return UICollectionReusableView()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 24)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PMD_reuseIdentifier, for: indexPath) as! PostMetadataCollectionViewCell
        let postMetadata = dataSource.postMetadata(at: indexPath)
        
        //Cell data
        cell.titleLabel.text = postMetadata.title
        cell.authorLabel.text = postMetadata.author.name
        cell.authorTitleLabel.text = postMetadata.author.title
        
        //Format the Date to a human readable
        let formatDate = DateFormatter()
        formatDate.dateFormat = "yyyy-MM-dd"
        let formatDateString = formatDate.string(from: postMetadata.publishDate)
        
        cell.publishDateLabel.text = formatDateString
        
        cell.summaryLabel.text = postMetadata.summary
        cell.summaryLabel.sizeThatFits(CGSize(width: self.view.frame.size.width, height: 12))
        cell.summaryLabel.sizeToFit()
        
        //pickup the server host, so it's not hard encoded
        let server_url = String(server.host.absoluteURL.absoluteString)
        let url = URL(string: server_url + postMetadata.author.image )
        
        /* This is pretty down and dirty. I wanted to see how the images would look on the page to show to the client.
           We may adopt a URL Session for images in the future with a callback.
           The image loads in the background and updates the foregrond when when */
        DispatchQueue.global().async {
            if let url = url, let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postMetadata = dataSource.postMetadata(at: indexPath)
        let postController = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        
        /* Proceed with the seque while we fetch our post, non-blocking */
        DispatchQueue.main.async {
            postController.post = nil
            self.navigationController?.pushViewController(postController, animated: true)
        }
        
        /* Use the id, the docs stated postId is not always accurate */
        let url = server.postUrlFor(id: postMetadata.id )
        
        //Get the one post. No since in filtering through a stack of posts
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
            
            let post: Post?
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                post = try decoder.decode(Post.self, from: data)
            } catch {
                self?.displayError(error: error)
                return
            }
            
            /* Update our post */
            postController.post = post
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
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: full width cells that fit any size screen
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 153)
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
                
                
                self?.dataSource.sortListByPosts(ascending: false)
                self?.dataSource.orgMetaDataList = (self?.dataSource.postMetadataList)!
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

