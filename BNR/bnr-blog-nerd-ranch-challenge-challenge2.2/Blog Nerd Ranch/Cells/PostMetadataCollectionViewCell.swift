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
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var authorTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        /* Make the image look nice in a circle */
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}

