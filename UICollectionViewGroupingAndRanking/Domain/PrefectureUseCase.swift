//
//  Prefecture.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/02/20.
//

import Foundation

final class PrefectureUseCase {
    let prefectureRepository: PrefectureRepository = PrefectureRepositoryImpl()
    var prefectures: [Prefecture] = []
    
    init() {
        prefectures = prefectureRepository.fetchPrefecturesData()
    }
    
    private var groups: [Group] {
        let setOfGroups = Set(prefectures.map { $0.group }) // 重複排除
        return setOfGroups.map { $0 }
    }
    var prefecturesByGroup: [[Prefecture]] {
        groups.map { group in
            prefectures.filter { prefecture in
                prefecture.group.ID == group.ID
            }
        }
    }
    
    private var currentPrefectures: [[Prefecture]] = [[]]
    var temporaryGroups: [Group] = []
    
    func getCurrentPrefecture(index: IndexPath) -> Prefecture {
        currentPrefectures[index.section][index.item]
    }
    
    func changeIsHiddenAndReturnPrefectures(isHidden: Bool) -> [[Prefecture]] {
        for prefecturesCount in 0..<currentPrefectures.count {
            for prefectureCount in 0..<currentPrefectures[prefecturesCount].count {
                currentPrefectures[prefecturesCount][prefectureCount].changeIsHidden(isHidden: isHidden)
            }
        }
        return currentPrefectures
    }
    
    func initialCurrentPrefecture() {
        currentPrefectures = prefecturesByGroup
    }
    
    func initialTemporaryGroup() {
        groups.forEach { temporaryGroups.append($0) }
    }
    
    func addGroups(group: Group) -> [[Prefecture]] {
        temporaryGroups.append(group)
        updateCurrentPrefectures()
        return currentPrefectures
    }
    
    func updataPrefecture(indexPath: IndexPath, group: Group) ->  [[Prefecture]] {
        currentPrefectures[indexPath.section][indexPath.row].group = group
        updateCurrentPrefectures()
        return currentPrefectures
    }
    
    private func updateCurrentPrefectures() {
        let currentPrefecturesFlatMepped = currentPrefectures.flatMap { $0 }
        let updataPrefecture =  temporaryGroups.map { group in
            currentPrefecturesFlatMepped.filter { prefecture in
                prefecture.group == group
            }
        }
        currentPrefectures = updataPrefecture
    }
}

private extension Prefecture {
    mutating func changeIsHidden(isHidden: Bool) {
        isHiddenRanking = isHidden
    }
}

