//
//  AnotherPhotoViewController.swift
//  PhotoBrowser
//
//  Created by Himalaya Rajput on 17/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class PhotoScrollerViewController: UIViewController {
    static let identifier = "PhotoScroller"
    private var imageArray = PhotoManager.shared.photos
    private var allowRightRepeat = true
    private var allowLeftRepeat = true
    private var spacing: CGFloat = 0.0
    var selectedRow: Int!
    lazy private var arrayCount: Int = {
           return imageArray.count
       }()
    
    @IBOutlet private weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        layoutCollectionView()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(row: selectedRow, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
        collectionView.alpha = 1.0
    }
    
    private func layoutCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .horizontal
        collectionView.isPagingEnabled = true
        collectionView.collectionViewLayout = layout
        collectionView.alpha = 0
    }
    
}

extension PhotoScrollerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScrollerCollectionViewCell.identifier, for: indexPath)
        if let cell = cell as? ScrollerCollectionViewCell {
            cell.currentPreviewImage = imageArray[indexPath.row % imageArray.count]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ScrollerCollectionViewCell {
            cell.scrollView.zoomScale = cell.initialZoomScale
        }
    }
}

extension PhotoScrollerViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let width = scrollView.contentSize.width
        if width != 0  {
            if offsetX < 0 {
                if allowLeftRepeat {
                    beginLeftRepeat()
                }
            } else if offsetX > width - scrollView.frame.width  {
                if allowRightRepeat {
                    beginRightRepeat()
                }
            } else {
                if allowLeftRepeat == false {
                    allowLeftRepeat = true
                }
            }
        }
    }
    
    private func beginRightRepeat() {
        if allowLeftRepeat {
            allowRightRepeat = false
            arrayCount += imageArray.count
            collectionView.reloadData()
            allowRightRepeat = true
        } else {
            allowLeftRepeat = true
        }
    }
    
    private func beginLeftRepeat() {
        allowLeftRepeat = false
        arrayCount += imageArray.count
        collectionView.reloadData()
        let indexpath = IndexPath(row: imageArray.count, section: 0)
        collectionView.scrollToItem(at: indexpath , at: .right, animated: false)
    }
}
