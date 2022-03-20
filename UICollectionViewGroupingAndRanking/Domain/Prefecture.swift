//
//  Prefecture.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/03/05.
//

import Foundation

extension Prefecture: Identifiable {}
extension Prefecture: Replacable {}

struct Prefecture: Hashable {
    let name: String
    var group: Group
    var isHiddenRanking: Bool = true
    let id: String
    var rank: Int?
}

struct Group: Hashable {
    var id: String
    var name: String
}

extension Array where Element: Replacable, Element: Identifiable {
    func replacing<T>(id: Element.ID,
                      keyPath: WritableKeyPath<Element, T>,
                      newValue: T) -> Self {
        map {
            $0.id == id
            ? $0.replacing(keyPath: keyPath, newValue: newValue)
            : $0
        }
    }
}
