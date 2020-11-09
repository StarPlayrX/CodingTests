//
//  PostMetadataDataSource.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 9/3/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import Foundation

var displayTitle = "BNR"

/// Group & sort posts based on the given ordering.
struct PostMetadataDataSource {
    /// Represents a named group of posts. The nature of the group depends on the ordering it was created with
    private struct Group {
        let name: String?
        var postMetadata: [PostMetadata]
    }
    
    var ordering: DisplayOrdering {
        didSet {
           // createGroups()
        }
    }
    
    var postMetadataList: [PostMetadata] {
        didSet {
            groups = []
            createGroups()
        }
    }
    
    var orgMetaDataList = [PostMetadata]()
    var groupDataList = [PostMetadata]()

    private var groups: [Group] = []
    
    init(ordering: DisplayOrdering, postMetadata: [PostMetadata] = []) {
        self.ordering = ordering
        self.postMetadataList = postMetadata
    }
    
    private mutating func createGroups() {
     
        
        if groups.isEmpty {
            groups = [Group(name: displayTitle, postMetadata: postMetadataList)]
        }
        
        
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
 
    
    // MARK: Grouping algorthims Start
    mutating func noGrouping() {
        postMetadataList = orgMetaDataList
    }
    
    //MARK: Group By author
    mutating func groupByauthor(weighted: Bool) {
        groups = []
        
        var authorDictionary = [String: [PostMetadata] ]()
        
        let list = orgMetaDataList.sorted() { $0.author.name < $1.author.name }
        
        for a in list {
            let author = a.author.name

            if let _ = authorDictionary.index(forKey: author) {
                authorDictionary[a.author.name]?.append(a)
            } else {
                authorDictionary[a.author.name] = [PostMetadata]()
                authorDictionary[a.author.name]?.append(a)
            }
        }
        
        var authorGroup = authorDictionary.sorted() {$0.key < $1.key}
        
        /* groups large quantities together */
        if weighted {
            authorGroup.sort() {$0.value.count > $1.value.count}
        }

        for b in authorGroup {
            if !b.value.isEmpty {
                groups.append(Group.init(name: b.key, postMetadata: b.value))
            }
        }
    }
    
    
    //MARK: Group By Month and Year (uses the same algorthim as groupByauthor)
    mutating func groupByMonthAndYear(weighted: Bool) {
        groups = []
        
        var monthYearDictionary = [String: [PostMetadata] ]()
        
        let list = orgMetaDataList.sorted() { $0.publishDate < $1.publishDate }
        
        for p in list {
            let pDate = p.publishDate
            
            let cal = Calendar.current
            let month = Int(cal.component(.month, from: pDate))
            let year = Int(cal.component(.year, from: pDate))
            let monthName = DateFormatter().monthSymbols[month - 1]
            let key =  String( "\(monthName) \(year)")
            
            if let _ = monthYearDictionary.index(forKey: key) {
                monthYearDictionary[key]?.append(p)
            } else {
                monthYearDictionary[key] = [PostMetadata]()
                monthYearDictionary[key]?.append(p)
            }
        }
        
        var monthGroup = monthYearDictionary.sorted() {$0.key > $1.key}
        
        /* groups large quantities together */
        if weighted {
            monthGroup.sort() {$0.value.count > $1.value.count}
        }

        for b in monthGroup {
            if !b.value.isEmpty {
                groups.append(Group.init(name: b.key, postMetadata: b.value))
            }
        }
    }
    

    // MARK: Sorting algorthims Start
    mutating func sortListByAuthor(ascending: Bool) {
        ascending ? postMetadataList.sort() { $0.author.name < $1.author.name } : postMetadataList.sort() { $0.author.name > $1.author.name }
    }
    
    mutating func sortListByTitle(ascending: Bool) {
        ascending ? postMetadataList.sort() { $0.title < $1.title } : postMetadataList.sort() { $0.title > $1.title }
    }
    
    mutating func sortListByPosts(ascending: Bool) {
        ascending ? postMetadataList.sort() { $0.publishDate > $1.publishDate } : postMetadataList.sort() { $0.publishDate < $1.publishDate }
    }
    // MARK: Sorting algorthims End

}
