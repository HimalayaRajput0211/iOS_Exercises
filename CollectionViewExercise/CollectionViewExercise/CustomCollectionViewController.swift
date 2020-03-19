//
//  ViewController.swift
//  CollectionViewExercise
//
//  Created by Himalaya Rajput on 18/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit

class CustomCollectionViewController: UIViewController {
    private var items = ["a", "b","c","d", "e","f","g", "h","i","j", "k","l","m", "n","o","p", "q","r","s", "t","u","v", "w","x","y","z"]
    private let spacing: CGFloat = 10.0
    private let insertingElements = ["A","B","C"]
    private var animatioDuration: Double {
        if let animationSpeed = animationSpeed.text , let duration = Double(animationSpeed) {
            return duration < 0 ? -duration : duration
        }
        return 0.0
    }
    lazy private var currentLayout: UICollectionViewFlowLayout = {
        return collectionView.collectionViewLayout as? CustomLayout ?? CustomLayout()
    }()
    private var cellHeight: CGFloat! { didSet { currentLayout.itemSize.height = cellHeight } }
    private var cellWidth: CGFloat! { didSet { currentLayout.itemSize.width = cellWidth } }
    private var cellItemSpacing: CGFloat! {
        didSet {
            currentLayout.minimumInteritemSpacing = cellItemSpacing
            currentLayout.minimumLineSpacing = cellItemSpacing
        }
    }
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    @IBOutlet private weak var itemSpacing: UITextField!
    @IBOutlet private weak var height: UITextField!
    @IBOutlet private weak var width: UITextField!
    @IBOutlet private weak var animationSpeed: UITextField!
    @IBOutlet private weak var animationSpeedStepper: UIStepper!
    @IBOutlet private weak var widthStepper: UIStepper!
    @IBOutlet private weak var heightStepper: UIStepper!
    @IBOutlet private weak var itemSpacingStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        setupTextFieldDelegation()
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    }
    
    @IBAction private func updateAnimationSpeed(_ sender: UIStepper) {
        animationSpeed.text = "\(sender.value)"
    }
    
    @IBAction private func updateWidth(_ sender: UIStepper) {
        width.text = "\(Int(sender.value))"
        cellWidth = CGFloat(sender.value)
    }
    
    @IBAction private func updateHeight(_ sender: UIStepper) {
        height.text = "\(Int(sender.value))"
        cellHeight = CGFloat(sender.value)
    }
    
    @IBAction private func updateItemSpacing(_ sender: UIStepper) {
        itemSpacing.text = "\(Int(sender.value))"
        cellItemSpacing = CGFloat(sender.value)
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
        cellWidth = CGFloat(width.text)
        cellHeight = CGFloat(height.text)
        cellItemSpacing = CGFloat(itemSpacing.text)
    }
    
    private func setupTextFieldDelegation() {
        itemSpacing.delegate = self
        width.delegate = self
        height.delegate = self
        animationSpeed.delegate = self
    }
    
    private func animate(_ completion: @escaping () ->  Void ) {
        UIView.animate(withDuration: animatioDuration) {
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
        let deleteIndexpath: [IndexPath] = getRequiredIndexpaths(from: items.endIndex - 3).reversed()
        items.removeLast(3)
        animate {
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: deleteIndexpath)
            }, completion: nil)
        }
    }
    
    private func updateItemAtSecondIndex() {
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
            cell.label.text = items[indexPath.row]
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.flipCardAnimationWith(animationDuration: animatioDuration) {
                self.items.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [indexPath])
            }
        }
    }
}

extension CustomCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let editingTextField = EditingTextField(rawValue: textField.tag)
        let value = CGFloat(textField.text)
        switch editingTextField {
        case .animationSpeed:
            animationSpeedStepper.value = Double(value)
        case .witdth:
            widthStepper.value = Double(value)
            animate {
                self.collectionView.performBatchUpdates({
                    self.cellWidth = value
                }, completion: nil)
            }
        case .height:
            heightStepper.value = Double(value)
            animate {
                self.collectionView.performBatchUpdates({
                    self.cellHeight = value
                }, completion: nil)
            }
        case .itemSpacing:
            itemSpacingStepper.value = Double(value)
            animate {
                self.collectionView.performBatchUpdates({
                    self.cellItemSpacing = value
                }, completion: nil)
            }
        default: break
        }
        if editingTextField == .animationSpeed {
            textField.text = "\(value)"
        } else {
            textField.text = "\(Int(value))"
        }
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
}

extension CustomCollectionViewController {
    enum EditingTextField: Int {
        case animationSpeed = 100
        case witdth = 101
        case height = 102
        case itemSpacing = 103
    }
}
