//
//  CommentViewController.swift
//  InteractiveAnimation
//
//  Created by Himalaya Rajput on 06/04/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    static let nibName: String = "CommentViewController"
    @IBOutlet weak var handleTouchView: UIView!
    @IBOutlet weak var collapsedTitleLabel: UILabel! {
        didSet {
            collapsedTitleLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            collapsedTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        }
    }
    @IBOutlet weak var expandedTitleLabel: UILabel! {
        didSet {
            expandedTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
            expandedTitleLabel.alpha = 0
            expandedTitleLabel.transform = CGAffineTransform.identity.scaledBy(x: 0.65, y: 0.65).concatenating(CGAffineTransform.identity.translatedBy(x: 0, y: -15))
        }
    }
}
