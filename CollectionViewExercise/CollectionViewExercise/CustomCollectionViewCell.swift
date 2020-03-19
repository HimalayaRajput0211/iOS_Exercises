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
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel()
        label.frame = self.frame
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.backgroundColor = .orange
        self.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = self.bounds
    }
    
    func flipCardAnimationWith(animationDuration duration: Double, completion: @escaping () -> Void) {
        UIView.transition(
            with: self.label,
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
