//
//  PostMetadata.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 8/28/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import Foundation

//MARK: updated with Summary and Author
struct PostMetadata: Codable {
    let id, title, postId, summary: String
    let publishDate: Date
    let author: Author
    
    //MARK: Author
    struct Author: Codable {
        let name, image, title: String
    }
}
