//
//  LabelBadge.swift
//  iRemember
//
//  Created by Paul Hudson on 26/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class LabelBadge: UICollectionReusableView {
    static let reuseIdentifier = "label-badge"
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}

