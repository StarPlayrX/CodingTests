//
//  PostMetadataDataSource.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 9/3/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import Foundation

var displayTitle = "BNR"

private var authorsSortingCache = false
private var monthYearSortingCache = false

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
    
    /* Grouping and Sorting Business Logic */
    
    //MARK: Group By Author
    mutating func groupByAuthor(sorting: Sorting) {
        
        print(sorting)
        var authorDictionary = [String: [PostMetadata] ]()
        
        let list = orgMetaDataList
        
        var authorSet = Set<String>() //Since we can't guarantee sort with both Set and Dictionarys, we will convert this to an array later as sort it, that in turn will be used as the Keys for the Dictionary
        //We used a set so we don't have to worry about duplicates, plus sets are very effcient
        
        for a in list {
            
            let author = a.author.name
            authorSet.insert(author)
            
            if let _ = authorDictionary.index(forKey: author) {
                authorDictionary[a.author.name]?.append(a)
            } else {
                authorDictionary[a.author.name] = [PostMetadata]()
                authorDictionary[a.author.name]?.append(a)
            }
        }
    
        var authorArray = Array(authorSet)
        
        switch sorting {
        
        //MARK: This sorts the outer group (by Author)
        case .alphabeticalByAuthor(ascending: let ascending):
            ascending ? authorArray.sort {$0 < $1} : authorArray.sort {$0 > $1}
            authorsSortingCache = ascending
        default :
            authorsSortingCache ? authorArray.sort {$0 < $1} :  authorArray.sort {$0 > $1}
        }
        

        groups = []
        for a in authorArray {
            
            switch sorting {
            
            //Sort the contents
            case .alphabeticalByTitle(ascending: let ascending):
                ascending ? authorDictionary[a]?.sort { $0.title < $1.title } : authorDictionary[a]?.sort { $0.title > $1.title }
            case .byPublishDate(recentFirst: let recentFirst):
                recentFirst ? authorDictionary[a]?.sort { $0.publishDate > $1.publishDate } : authorDictionary[a]?.sort { $0.publishDate < $1.publishDate }
            default :
                authorDictionary[a]?.sort { $0.title < $1.title } //defaults to sorted by title
            }
            
            let obj = authorDictionary[a]! as [PostMetadata]
            groups.append(Group.init(name: a, postMetadata: obj))
        }
    }
    
    //MARK: Group By Month and Year
    mutating func groupByMonthAndYear(sorting: Sorting) {
        
        var monthYearDictionary = [String: [PostMetadata] ]()
        
        let list = orgMetaDataList
        
        var monthYearSet = Set<String>() //Since we can't guarantee sort with both Set and Dictionarys, we will convert this to an array later and sort it, that in turn will be used as the Keys for the Dictionary
        //We used a set so we don't have to worry about duplicates, plus sets are very effcient
        
        for p in list {
            
            let pDate = p.publishDate
            
            let cal = Calendar.current
            let month = Int(cal.component(.month, from: pDate))
            let year = Int(cal.component(.year, from: pDate))
            let monthName = DateFormatter().monthSymbols[month - 1]
            let key =  String( "\(monthName) \(year)")
            
            monthYearSet.insert(key)

            if let _ = monthYearDictionary.index(forKey: key) {
                monthYearDictionary[key]?.append(p)
            } else {
                monthYearDictionary[key] = [PostMetadata]()
                monthYearDictionary[key]?.append(p)
            }
        }
    
        var monthYearArray = Array(monthYearSet)
        
        switch sorting {
        
        //MARK: This sorts the outer group (by Author)
        case .byPublishDate(recentFirst: let recentFirst):
            recentFirst ? monthYearArray.sort {$0 < $1} : monthYearArray.sort {$0 > $1}
            monthYearSortingCache = recentFirst
        default :
            monthYearSortingCache ? monthYearArray.sort {$0 < $1} :  monthYearArray.sort {$0 > $1}
        }

        groups = []
        for m in monthYearArray {
            
            //Sort the contents
            switch sorting {
            
            case .alphabeticalByAuthor(ascending: let ascending):
                ascending ? monthYearDictionary[m]?.sort { $0.author.name < $1.author.name } : monthYearDictionary[m]?.sort { $0.author.name > $1.author.name }
            case .alphabeticalByTitle(ascending: let ascending):
                ascending ? monthYearDictionary[m]?.sort { $0.title < $1.title } : monthYearDictionary[m]?.sort { $0.title > $1.title }
            case .byPublishDate(recentFirst: let recentFirst):
                recentFirst ? monthYearDictionary[m]?.sort { $0.publishDate > $1.publishDate } : monthYearDictionary[m]?.sort { $0.publishDate < $1.publishDate }
            }
            
            let obj = monthYearDictionary[m]! as [PostMetadata]
            groups.append(Group.init(name: m, postMetadata: obj))
        }
    }
    

    
    
    // MARK: Sorting algorthims Start
    
    //Sort by Author
    mutating func sortListByAuthor(ascending: Bool, sorting: Sorting, grouping: Grouping) {
    
        //Group by
        switch grouping {
        
        //No Groups (single array)
        case .none:
            ascending ? postMetadataList.sort() { $0.author.name < $1.author.name } : postMetadataList.sort() { $0.author.name > $1.author.name }
            
        //Group by Author and sort by author
        case .author:
            groupByAuthor(sorting: sorting)
            
        //Group by Month + Year and sort by author
        case .month:
            groupByMonthAndYear(sorting: sorting)
        }
       
    }
    
    //Sort by Title
    mutating func sortListByTitle(ascending: Bool, sorting: Sorting, grouping: Grouping) {
        
        //Group by
        switch grouping {
        
        //No Groups (single array)
        case .none:
            ascending ? postMetadataList.sort() { $0.title < $1.title } : postMetadataList.sort() { $0.title > $1.title }
            
        //Group by Author and sort by title
        case .author:
            groupByAuthor(sorting: sorting)
            
        //Group by Month + Year and sort by title
        case .month:
            groupByMonthAndYear(sorting: sorting)
        }
        
    }
    
    //Sort by Posts
    mutating func sortListByPosts(ascending: Bool, sorting: Sorting, grouping: Grouping ) {
        
        //Group by
        switch grouping {
        
        //No Groups (single array)
        case .none:
            ascending ? postMetadataList.sort() { $0.publishDate > $1.publishDate } : postMetadataList.sort() { $0.publishDate < $1.publishDate }
            
        //Group by Author and sort by posts
        case .author:
            groupByAuthor(sorting: sorting)
            
        //Group by Month + Year and sort by posts
        case .month:
            groupByMonthAndYear(sorting: sorting)
        }
    
    }
    // MARK: Sorting algorthims End

}
