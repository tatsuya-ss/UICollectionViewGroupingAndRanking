//
//  Identifierable.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/02/20.
//

import Foundation
import UIKit

protocol Identifierable {
    static var identifier: String { get }
    static var nib: UINib { get }
}

extension Identifiable where Self: UICollectionViewCell {
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
}
