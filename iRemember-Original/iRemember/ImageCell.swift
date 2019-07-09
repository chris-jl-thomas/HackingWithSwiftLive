//
//  ImageCell.swift
//  iRemember
//
//  Created by Paul Hudson on 26/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    static let reuseIdentifier = "image-cell"
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}
