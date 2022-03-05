//
//  PrefectureRepository.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/03/05.
//

import Foundation

protocol PrefectureRepository {
    func fetchPrefecturesData() -> [Prefecture]
}
