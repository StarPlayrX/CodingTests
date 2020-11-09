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
    
    var loading = "Loading..."
    var emptyString = ""
    var activityView: UIActivityIndicatorView?
    
    var post: Post? {
        didSet {
            renderPost()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if let titleLabel = titleLabel {
            titleLabel.text = loading
            titleLabel.alpha = 0.45
        } else if let titleLabel = titleLabel, let contentsLabel = contentsLabel {
            titleLabel.text = emptyString
            contentsLabel.text = emptyString
        }
    }
    
   
    func showActivityIndicator() {
        if #available(iOS 13.0, *) {
            activityView = UIActivityIndicatorView(style: .large)
        } else {
            // Fallback on earlier versions
            activityView = UIActivityIndicatorView(style: .gray)
        }
        
        if let actView = activityView {
            actView.center = self.view.center
            self.view.addSubview(actView)
            actView.startAnimating()
        }
    }

    func hideActivityIndicator(){
        if let actView = activityView {
            actView.stopAnimating()
        }
        
        if let titleLabel = titleLabel {
            titleLabel.alpha = 1.0
        }
    }
    
   
    private func renderPost() {
        
        DispatchQueue.main.async { [self] in
            if let post = post {
                hideActivityIndicator()
                titleLabel.text = post.metadata.title
                contentsLabel.text = post.body
            } else {
                showActivityIndicator()
                titleLabel.text = loading
                contentsLabel.text = emptyString
            }
        }
    }
    
}
