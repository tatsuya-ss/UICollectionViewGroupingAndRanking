//
//  PrefectureRepositoryImpl.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/03/05.
//

import Foundation

final class PrefectureRepositoryImpl: PrefectureRepository {
    private let prefecturesData = PrefecturesData()
    
    func fetchPrefecturesData() -> [Prefecture] {
        prefecturesData.prefecturesData.map { Prefecture(prefectureData: $0) }
    }
}

private extension Prefecture {
    init(prefectureData: PrefectureData) {
        self = Prefecture(name: prefectureData.name,
                          group: Group(groupData: prefectureData.group),
                          ID: prefectureData.ID,
                          rank: prefectureData.rank)
    }
}

private extension Group {
    init(groupData: GroupData) {
        self = Group(ID: groupData.ID,
                     name: groupData.name)
    }
}
