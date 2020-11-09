//
//  Server.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 8/31/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import Foundation

/// This represents a server that supports our Blog API. It provides convenient
/// properties & methods for all the API's endpoints, given a host.
struct Server {
    /// The base URL representing the API.
    let host: URL
    
    /// URL to get metadata for all posts
    var allPostMetadataUrl: URL {
        return host.appendingPathComponent("/post-metadata")
    }
    
    /// Get the URL to query for metadata for a specific metadata ID
    ///
    /// - Parameter id: Metadata ID used to uniquely identify this metadata.
    /// - Returns: URL to query to get metadata for that ID
    func postMetadataUrlFor(id: String) -> URL {
        return host.appendingPathComponent("/post-metadata/\(id)")
    }
    
    /// URL to get data for all posts
    var allPostsUrl: URL {
        return host.appendingPathComponent("/post")
    }
    
    /// Get the URL to query for post data for a specific post ID
    ///
    /// - Parameter id: Post ID used to uniquely identify this post.
    /// - Returns: URL to query to get post data for that ID.
    func postUrlFor(id: String) -> URL {
        return host.appendingPathComponent("/post/\(id)")
    }
}

/// A collection of servers to test against. Right now, we only support a mock server.
enum Servers {
    static let mock = Server(host: URL(string: "http://localhost:8080")!)
}
