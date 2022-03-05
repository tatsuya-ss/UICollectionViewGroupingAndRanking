//
//  ViewController.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/02/20.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Group, Prefecture>! = nil
    private var prefectureManager = PrefectureManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        prefectureManager.initialCurrentPrefecture()
        prefectureManager.initialTemporaryGroup()
        configureHierarchy()
        configureDataSource()
        initialDataSource()
        
    }
    
    @IBAction func didTapAddGroupButton(_ sender: Any) {
        let addGroupVC = AddGroupViewController.instantiate()
        addGroupVC.makeGroup(createGroup: { [weak self] group in
            let updataPrefectures = self?.prefectureManager.addGroups(group: group)
            self?.updateDataSource(prefecturesByRegion: updataPrefectures ?? [[]])
        })
        present(addGroupVC, animated: true, completion: nil)
    }
    
}

// MARK: - func
extension ViewController {
    
    private func updateDataSource(prefecturesByRegion: [[Prefecture]]) {
        var snapshot = NSDiffableDataSourceSnapshot<Group, Prefecture>()
        let group = prefectureManager.temporaryGroups
        group.forEach {
            snapshot.appendSections([$0])
        }
        prefecturesByRegion.forEach { prefectures in
            prefectures.forEach {
                snapshot.appendItems([$0], toSection: $0.group)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func initialDataSource() {
        let prefecturesByRegion = prefectureManager.prefecturesByGroup
        updateDataSource(prefecturesByRegion: prefecturesByRegion)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Group, Prefecture>(
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
            let groupName = self.prefectureManager.temporaryGroups[indexPath.section].name
            supplementaryView.label.text = groupName
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
    
    private func setupNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupName = prefectureManager.temporaryGroups[indexPath.section].name
        let didSelectPrefectureName = prefectureManager.getCurrentPrefecture(index: indexPath).name
        let alert = UIAlertController(title: "\(groupName)から\(didSelectPrefectureName)を移動", message: nil, preferredStyle: .alert)
        prefectureManager.temporaryGroups.forEach { (group: Group) -> Void in alert.addAction(UIAlertAction(title: group.name, style: .default, handler: { [weak self] _ in
            guard let updataPrefectures = self?.prefectureManager.updataPrefecture(indexPath: indexPath, group: group) else { return }
            self?.updateDataSource(prefecturesByRegion: updataPrefectures)
        })) }
        present(alert, animated: true, completion: nil)
    }
    
}
