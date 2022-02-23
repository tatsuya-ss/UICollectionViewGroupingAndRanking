//
//  ViewController.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/02/20.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<LocalType, Prefecture>! = nil
    private var prefectures = Prefectures().prefectures
    private var prefecturesByRegion: [[Prefecture]] = [[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureDataSource()
        initialDataSource()
        
    }
    
}

// MARK: - func
extension ViewController {
    
    private func makePrefecturesByRegion(prefectures: [Prefecture]) -> [[Prefecture]] {
        let prefecturesByRegion = LocalType.allCases.map { type in
            prefectures.filter { prefecture in
                prefecture.localType == type
            }
        }
        self.prefecturesByRegion = prefecturesByRegion
        return prefecturesByRegion
    }
    
    private func makePrefectures(prefectures: [[Prefecture]]) -> [Prefecture] {
        prefectures.flatMap { $0 }
    }
    
    private func updateDataSource(prefecturesByRegion: [[Prefecture]]) {
        var snapshot = NSDiffableDataSourceSnapshot<LocalType, Prefecture>()
        LocalType.allCases.forEach {
            snapshot.appendSections([$0])
        }
        prefecturesByRegion.forEach { prefectures in
            prefectures.forEach {
                snapshot.appendItems([$0], toSection: $0.localType)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updatePrefecturesByRegion() {
        let flatPrefecture = prefecturesByRegion.flatMap { $0 }
        let updatePrefectures = makePrefecturesByRegion(prefectures: flatPrefecture)
        updateDataSource(prefecturesByRegion: updatePrefectures)
    }
    
    private func initialDataSource() {
        let prefecturesByRegion = makePrefecturesByRegion(prefectures: prefectures)
        updateDataSource(prefecturesByRegion: prefecturesByRegion)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<LocalType, Prefecture>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CollectionViewCell.identifier,
                    for: indexPath
                ) as? CollectionViewCell
                else { fatalError("CollectionViewCellが見つかりませんでした。") }
                cell.configure(title: itemIdentifier.name)
                return cell
            })
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: "header-element-kind") { supplementaryView, elementKind, indexPath in
            let sectionKind = LocalType(rawValue: indexPath.section)
            supplementaryView.label.text = sectionKind?.name
        }
        
        dataSource.supplementaryViewProvider = { view, kind, index in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
        }
    }
    
    private func configureHierarchy() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.register(CollectionViewCell.nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 6)
            let section = NSCollectionLayoutSection(group: group)
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(44)),
                elementKind: "header-element-kind",
                alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }, configuration: config)
        return layout
    }
    
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let groupName = LocalType(rawValue: indexPath.section)?.name
        let alert = UIAlertController(title: "\(groupName ?? "不明")からの移動", message: nil, preferredStyle: .alert)
        LocalType.allCases.forEach { (localType: LocalType) -> Void in alert.addAction(UIAlertAction(title: localType.name, style: .default, handler: { [weak self] _ in
            print(self!.prefecturesByRegion[indexPath.section][indexPath.row])
            self?.prefecturesByRegion[indexPath.section][indexPath.row].localType = localType
            self?.updatePrefecturesByRegion()
        })) }
        present(alert, animated: true, completion: nil)
    }
    
}
