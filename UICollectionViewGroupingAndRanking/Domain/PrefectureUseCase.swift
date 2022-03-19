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
    
    // prefecturesByGroupが読み取り専用なので保持する用
    private(set) var currentPrefectures: [[Prefecture]] = [[]]
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
    
    func updataPrefecture(indexPath: IndexPath, group: Group) {
        if currentPrefectures[indexPath.section][indexPath.item].group != group {
            // 別グループに移動するためランキングを消す
            deleteRanking(indexPath: indexPath)
        }
        currentPrefectures[indexPath.section][indexPath.item].group = group
        updateCurrentPrefectures()
    }
    
    private func deleteRanking(indexPath: IndexPath) {
        currentPrefectures[indexPath.section][indexPath.item].rank = nil
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
    
    func changeRanking(indexPath: IndexPath) {
        var rankingManager = RankingManager()
        rankingManager.updateCurrentRankign(prefectures: currentPrefectures[indexPath.section])
        let isRanked = currentPrefectures[indexPath.section][indexPath.item].rank != nil
        if isRanked {
            currentPrefectures[indexPath.section][indexPath.item].rank = nil
        } else {
            currentPrefectures[indexPath.section][indexPath.item].rank = rankingManager.currentRanking
        }
    }
    
    func sortByRanking() {
        // 並び替え参考記事 https://qiita.com/mishimay/items/59fba10170ed2ff7690a
        currentPrefectures = currentPrefectures.map { prefectures in
            prefectures.sorted { l, r in
                switch (l.rank, r.rank) {
                case (.some(let l), .some(let r)):
                    return l < r
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return false
                }
            }
        }
    }
}

private extension Prefecture {
    mutating func changeIsHidden(isHidden: Bool) {
        isHiddenRanking = isHidden
    }
}

struct RankingManager {
    private(set) var currentRanking = 0
    
    private mutating func nextRanking() {
        currentRanking += 1
    }
    
    mutating func updateCurrentRankign(prefectures: [Prefecture]) {
        prefectures.forEach {
            guard let ranking = $0.rank else { return }
            currentRanking = ranking > currentRanking
            ? ranking : currentRanking
        }
        nextRanking()
    }
}
