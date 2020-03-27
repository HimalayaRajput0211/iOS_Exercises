//
//  CustomCollectionViewCell.swift
//  CollectionViewExercise
//
//  Created by Himalaya Rajput on 19/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class CustomCollectionViewCell: UICollectionViewCell {
    static let identifier = "Cell"
    @IBOutlet weak var customLabel: UILabel!
    
    func flipCardAnimationWith(animationDuration duration: Double, completion: @escaping () -> Void) {
        UIView.transition(
            with: self.customLabel,
            duration: duration,
            options: [.transitionFlipFromLeft],
            animations: nil)
        { success in
            if success {
                completion()
            }
        }
    }
}
