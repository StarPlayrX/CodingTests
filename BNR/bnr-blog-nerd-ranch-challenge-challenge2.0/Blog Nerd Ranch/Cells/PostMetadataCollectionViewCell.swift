////  PostMetadataCollectionViewCell.swift
//  Blog Nerd Ranch
//
//  Created on 10/26/20.
//  Copyright © 2020 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PostMetadataCollectionViewCell: UICollectionViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var publishDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.authorLabel.text = ""
        self.summaryLabel.text = ""
        self.publishDateLabel.text = ""
    }

}
