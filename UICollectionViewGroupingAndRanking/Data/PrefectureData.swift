//
//  PrefectureData.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/03/05.
//

import Foundation

struct PrefecturesData {
    private let prefectureNames = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    let defaultGroup = GroupData(ID: UUID().uuidString, name: "デフォルト")
    var prefecturesData: [PrefectureData] {
        return prefectureNames.map {
            PrefectureData(name: $0,
                           group: defaultGroup,
                           ID: UUID().uuidString)
        }
    }
}

struct PrefectureData: Hashable {
    let name: String
    var group: GroupData
    var isHiddenRanking: Bool = true
    let ID: String
    var rank: Int?
}

struct GroupData: Hashable {
    var ID: String
    var name: String
}
