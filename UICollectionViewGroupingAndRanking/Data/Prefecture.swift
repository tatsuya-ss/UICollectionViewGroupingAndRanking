//
//  Prefecture.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/02/20.
//

import Foundation

struct Prefecture: Hashable {
    let name: String
    var localType: LocalType = .Hokkaido
    var group: Group
}

struct Group: Hashable {
    var ID: String
    var name: String
}

enum LocalType: Int, CaseIterable {
    case Hokkaido, Tohoku, Kanto, Chubu, Kinki, Chugoku, Shikoku, Kyushu, Okinawa
    var name: String {
        switch self {
        case .Hokkaido: return "北海道"
        case .Tohoku: return "東北"
        case .Kanto: return "関東"
        case .Chubu: return "中部"
        case .Kinki: return "近畿"
        case .Chugoku: return "中国"
        case .Shikoku: return "四国"
        case .Kyushu: return "九州"
        case .Okinawa: return "沖縄"
        }
    }
}

struct PrefectureManager {
    let prefectureNames = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    let defaultGroup = Group(ID: UUID().uuidString, name: "デフォルト")
    var prefectures: [Prefecture] {
        return prefectureNames.map {
            Prefecture(name: $0, group: defaultGroup)
        }
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
    
    mutating func addGroups(group: Group) -> [[Prefecture]] {
        temporaryGroups.append(group)
        let currentPrefecturesFlatMepped = currentPrefectures.flatMap { $0 }
        let updataPrefecture =  temporaryGroups.map { group in
            currentPrefecturesFlatMepped.filter { prefecture in
                prefecture.group == group
            }
        }
        currentPrefectures = updataPrefecture
        return currentPrefectures
    }
    
    mutating func initialCurrentPrefecture() {
        currentPrefectures = prefecturesByGroup
    }
    
    mutating func initialTemporaryGroup() {
        groups.forEach { temporaryGroups.append($0) }
    }
    
    mutating func updataPrefecture(indexPath: IndexPath, group: Group) ->  [[Prefecture]] {
        currentPrefectures[indexPath.section][indexPath.row].group = group
        let currentPrefecturesFlatMepped = currentPrefectures.flatMap { $0 }
        let updataPrefecture =  temporaryGroups.map { group in
            currentPrefecturesFlatMepped.filter { prefecture in
                prefecture.group == group
            }
        }
        currentPrefectures = updataPrefecture
        return currentPrefectures
    }
}
