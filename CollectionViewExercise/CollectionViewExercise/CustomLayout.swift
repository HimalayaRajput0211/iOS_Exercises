//
//  CustomLayout.swift
//  CollectionViewExercise
//
//  Created by Himalaya Rajput on 19/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class CustomLayout : UICollectionViewFlowLayout {
    var updatedIndexPaths = [IndexPath]()
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        for updateItem in updateItems {
            if let indexpath = updateItem.indexPathAfterUpdate {
                updatedIndexPaths.append(indexpath)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        updatedIndexPaths.removeAll()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        if updatedIndexPaths.contains(itemIndexPath) {
           attributes?.alpha = 0.0
           attributes?.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        }
        return attributes
    }
}
