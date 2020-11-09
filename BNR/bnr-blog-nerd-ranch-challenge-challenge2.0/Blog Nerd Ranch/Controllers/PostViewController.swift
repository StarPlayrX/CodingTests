//
//  PostViewController.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 8/28/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    
    var post: Post? {
        didSet {
            if titleLabel != nil && contentsLabel != nil {
                renderPost()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        renderPost()
    }

    private func renderPost() {
        guard let post = post else {
            return
        }
        titleLabel.text = post.metadata.title
        contentsLabel.text = post.body
    }
    
}
