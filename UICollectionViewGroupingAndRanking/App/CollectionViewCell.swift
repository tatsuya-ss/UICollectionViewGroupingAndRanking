//
//  CollectionViewCell.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/02/20.
//

import UIKit

extension CollectionViewCell: Identifiable { }

final class CollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }

}
