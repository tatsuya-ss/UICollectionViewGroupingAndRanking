//
//  Replacable.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/03/20.
//

import Foundation

protocol Replacable {}

extension Replacable {
    func replacing<T>(keyPath: WritableKeyPath<Self, T>, newValue: T) -> Self {
        var result = self
        result[keyPath: keyPath] = newValue
        return result
    }
}

