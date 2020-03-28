//
//  ViewController.swift
//  CollectionViewExercise
//
//  Created by Himalaya Rajput on 18/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit

class CustomCollectionViewController: UIViewController {
    static let identifier = "CustomCollectionVC"
    private var items = ["a", "b","c","d", "e","f","g", "h","i","j", "k","l","m", "n","o","p", "q","r","s", "t","u","v", "w","x","y","z"]
    private let spacing: CGFloat = 10.0
    private let insertingElements = ["A","B","C"]
    var animationDuration: Double!
    lazy private var currentLayout: UICollectionViewFlowLayout = {
        return collectionView.collectionViewLayout as? CustomLayout ?? CustomLayout()
    }()
    var cellHeight: CGFloat!
    var cellWidth: CGFloat!
    var cellItemSpacing: CGFloat!
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentLayout.itemSize.height = cellHeight
        currentLayout.itemSize.width = cellWidth
        currentLayout.minimumInteritemSpacing = cellItemSpacing
        currentLayout.minimumLineSpacing = cellItemSpacing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
    }
    
    @IBAction private func performOperation(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: insertThreeItemsAtEnd()
        case 1: deleteThreeItemsAtEnd()
        case 2: updateItemAtSecondIndex()
        case 3: moveItemToEnd()
        case 4: deleteThreeItemsAtBeginningThenInsertThreeItemsAtEnd()
        case 5: insertThreeItemsAtEndThenDeleteThreeItemsAtBeginning()
        default: break
        }
    }
    
    private func setupCollectionViewLayout() {
        let layout = CustomLayout()
        collectionView.collectionViewLayout = layout
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
    }
    
    
    private func animate(_ completion: @escaping () ->  Void ) {
        UIView.animate(withDuration: animationDuration) {
            completion()
        }
    }
    
    private func getRequiredIndexpaths(from startIndex: Int) -> [IndexPath] {
        let endIndex = startIndex + 2
        return Array(startIndex...endIndex).map { IndexPath(row: $0)}
    }
    
    private func insertThreeItemsAtEnd() {
        let insertingIndexpath = getRequiredIndexpaths(from: items.endIndex)
        items.append(contentsOf: insertingElements)
        animate {
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: insertingIndexpath)
            }, completion: nil)
        }
    }
    
    private func deleteThreeItemsAtEnd() {
        guard items.count > 2 else { return }
        let deleteIndexpath: [IndexPath] = getRequiredIndexpaths(from: items.endIndex - 3).reversed()
        items.removeLast(3)
        animate {
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: deleteIndexpath)
            }, completion: nil)
        }
    }
    
    private func updateItemAtSecondIndex() {
        guard items.count > 2 else { return }
        items[2] = "🦕"
        let updatingIndexpath = [IndexPath(row: 2)]
        animate {
            self.collectionView.reloadItems(at: updatingIndexpath)
        }
    }
    
    private func moveItemToEnd() {
        let itemToMove = "e"
        if let index: Int = items.firstIndex(of: itemToMove) {
            items.remove(at: index)
            items.append(itemToMove)
            let souceIndexpath = IndexPath(row: index)
            let destinationIndexPath = IndexPath(row: items.index(before: items.endIndex))
            animate {
                self.collectionView.moveItem(at: souceIndexpath, to: destinationIndexPath)
            }
        }
    }
    
    private func deleteThreeItemsAtBeginningThenInsertThreeItemsAtEnd() {
        guard items.count > 2 else { return }
        let deletingIndexPaths = getRequiredIndexpaths(from: items.startIndex)
        items.removeFirst(3)
        animate { [unowned self] in
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: deletingIndexPaths)
            }) { success in
                if success {
                    let insertingIndexPaths = self.getRequiredIndexpaths(from: self.items.endIndex)
                    self.items.append(contentsOf: self.insertingElements)
                    self.animate {
                        self.collectionView.performBatchUpdates({
                            self.collectionView.insertItems(at: insertingIndexPaths)
                        }, completion: nil)
                    }
                }
            }
        }
    }
    
    private func insertThreeItemsAtEndThenDeleteThreeItemsAtBeginning() {
        let insertingIndexPaths = self.getRequiredIndexpaths(from: self.items.endIndex)
        items.append(contentsOf: insertingElements)
        animate { [unowned self] in
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: insertingIndexPaths)
            }) { success in
                if success {
                    let deletingIndexPaths = self.getRequiredIndexpaths(from: self.items.startIndex)
                    self.items.removeFirst(3)
                    self.animate {
                        self.collectionView.performBatchUpdates({
                            self.collectionView.deleteItems(at: deletingIndexPaths)
                        }, completion: nil)
                    }
                }
            }
        }
    }
    
}

extension CustomCollectionViewController: UICollectionViewDataSource , UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath)
        if let cell = cell as? CustomCollectionViewCell {
            cell.customLabel.text = items[indexPath.row]
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            collectionView.allowsSelection = false
            cell.flipCardAnimationWith(animationDuration: animationDuration) {
                self.items.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [indexPath])
                self.collectionView.allowsSelection = true
            }
        }
    }
}

