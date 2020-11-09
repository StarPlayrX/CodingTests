//
//  PostMetadataDataSource.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 9/3/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import Foundation

/// Group & sort posts based on the given ordering.
struct PostMetadataDataSource {
    /// Represents a named group of posts. The nature of the group depends on the ordering it was created with
    private struct Group {
        let name: String?
        var postMetadata: [PostMetadata]
    }
    
    var ordering: DisplayOrdering {
        didSet {
            createGroups()
        }
    }
    var postMetadataList: [PostMetadata] {
        didSet {
            createGroups()
        }
    }
    
    private var groups: [Group] = []
    
    init(ordering: DisplayOrdering, postMetadata: [PostMetadata] = []) {
        self.ordering = ordering
        self.postMetadataList = postMetadata
        createGroups()
    }
    
    private mutating func createGroups() {
        // TODO: Group and sort the posts according to the `ordering` value.
        groups = [Group(name: nil, postMetadata: postMetadataList)]
    }
    
    // MARK: UICollectionViewDataSource convenience
    
    func numberOfSections() -> Int {
        return groups.count
    }
    
    func titleForSection(_ section: Int) -> String? {
        return groups[section].name
    }
    
    func numberOfPostsInSection(_ section: Int) -> Int {
        return groups[section].postMetadata.count
    }
    
    func postMetadata(at indexPath: IndexPath) -> PostMetadata {
        return groups[indexPath.section].postMetadata[indexPath.row]
    }
 
    // MARK: Grouping
        
    // MARK: Sorting
    
}
