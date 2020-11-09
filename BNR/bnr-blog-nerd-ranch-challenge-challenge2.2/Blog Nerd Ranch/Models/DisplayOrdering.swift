//
//  Grouping.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 9/3/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import Foundation

/// Represents how posts can be grouped in the list
///
/// - none: No grouping. Show them all in a single list.
/// - author: Group the posts by their author.
/// - month: Group the posts by the month & year they were published.
enum Grouping {
    case none
    case author
    case month
}

/// Represents how the posts in each group should be sorted
///
/// - alphabeticalByAuthor: Sort by the author's name. If ascending is true, sort A to Z. Sort Z to A otherwise.
/// - alphabeticalByTitle: Sort by the title of the post. If ascending is true, sort A to Z. Sort Z to A otherwise.
/// - byPublishDate: Sort by the date the post was published. If recentFirst is true, show the most recent posts first. Otherwise, display them in the order they were published.
enum Sorting {
    case alphabeticalByAuthor(ascending: Bool)
    case alphabeticalByTitle(ascending: Bool)
    case byPublishDate(recentFirst: Bool)
}

/// This represents all state needed to determine the order to display the posts in: a grouping & a sorting.
public struct DisplayOrdering {
    var grouping: Grouping
    var sorting: Sorting
}

extension DisplayOrdering: CustomDebugStringConvertible {
    public var debugDescription: String {
        let groupString: String?
        switch grouping {
        case .author:
            groupString = "Group by author"
        case .month:
            groupString = "Group by published month"
        default:
            groupString = nil
        }
        
        let sortString: String
        switch sorting {
        case .alphabeticalByTitle(let ascending):
            sortString = "Sort by title from \(ascending ? "A to Z" : "Z to A")"
        case .alphabeticalByAuthor(let ascending):
            sortString = "Sort by author from \(ascending ? "A to Z" : "Z to A")"
        case .byPublishDate(let recentFirst):
            sortString = "Sort by publish date \(recentFirst ? "with recent posts first" : "chronologically")"
        }
        
        if let groupString = groupString {
            return "\(groupString), then \(sortString.lowercased())"
        } else {
            return sortString
        }
    }
}
