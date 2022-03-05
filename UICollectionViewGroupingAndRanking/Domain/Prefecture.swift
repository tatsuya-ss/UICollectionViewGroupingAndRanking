//
//  Prefecture.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/03/05.
//

import Foundation

struct Prefecture: Hashable {
    let name: String
    var group: Group
    var isHiddenRanking: Bool = true
}

struct Group: Hashable {
    var ID: String
    var name: String
    var rank: Int?
}
