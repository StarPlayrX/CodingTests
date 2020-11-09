//
//  PostMetadataCollectionViewCell.swift
//  Blog Nerd Ranch
//
//  Created by Chris Downie on 8/28/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PostMetadataCollectionViewCell: UICollectionViewCell {
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits = UIAccessibilityTraits.staticText
        titleLabel.accessibilityLabel = "Post Title"
        
        contentView.addSubview(titleLabel)
        
        // autolayout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalToSystemSpacingAfter: contentView.leftAnchor, multiplier: 1),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            contentView.rightAnchor.constraint(equalToSystemSpacingAfter: titleLabel.rightAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1)
        ])
        
        // Style the content view with a border & a drop-shadow
        contentView.backgroundColor = .white
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
        contentView.layer.shadowOpacity = 0.2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}
