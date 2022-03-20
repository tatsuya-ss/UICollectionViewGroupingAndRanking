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
                prefecture.group.id == group.id
            }
        }
    }
    
    // prefecturesByGroupが読み取り専用なので保持する用
    private(set) var currentPrefectures: [[Prefecture]] = [[]]
    var temporaryGroups: [Group] = []
    
    func getCurrentPrefecture(index: IndexPath) -> Prefecture {
        currentPrefectures[index.section][index.item]
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
        rankingManager.updateCurrentRanking(prefectures: currentPrefectures[indexPath.section])
        // 表示用のViewObjectとか作成したらid渡すだけでいけそう
        let id = currentPrefectures[indexPath.section][indexPath.item].id
        let isRanked = currentPrefectures[indexPath.section][indexPath.item].rank != nil
        if isRanked {
            currentPrefectures = currentPrefectures.map {
                $0.replacing(id: id, keyPath: \.rank, newValue: nil)
            }
        } else {
            currentPrefectures = currentPrefectures.map {
                $0.replacing(id: id, keyPath: \.rank, newValue: rankingManager.currentRanking)
            }
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

struct RankingManager {
    private(set) var currentRanking = 0
    
    private mutating func nextRanking() {
        currentRanking += 1
    }
    
    mutating func updateCurrentRanking(prefectures: [Prefecture]) {
        prefectures.forEach {
            guard let ranking = $0.rank else { return }
            currentRanking = ranking > currentRanking
            ? ranking : currentRanking
        }
        nextRanking()
    }
}
