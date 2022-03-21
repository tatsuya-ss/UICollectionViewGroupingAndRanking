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
    @IBOutlet private weak var rankLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
    
    func configure(title: String, isHiddenRank: Bool, rank: Int?) {
        titleLabel.text = title
        rankLabel.isHidden = isHiddenRank
        rankLabel.text = String(rank ?? 0)
    }

}
