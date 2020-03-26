//
//  AnotherCollectionViewCell.swift
//  PhotoBrowser
//
//  Created by Himalaya Rajput on 17/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit

class ScrollerCollectionViewCell: UICollectionViewCell {
    static let identifier = "ScrollerCell"
    private(set) var initialZoomScale: CGFloat!
    @IBOutlet private weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 4.0
        }
    }
    private var imageView: UIImageView!
    var currentPreviewImage: UIImage? {
        didSet {
            if imageView != nil {
                imageView.removeFromSuperview()
            }
            imageView = UIImageView()
            imageView.image = currentPreviewImage
            let size = currentPreviewImage?.size ??  CGSize.zero
            imageView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
            scrollViewWidth.constant = size.width
            scrollViewHeight.constant = size.height
            scrollView.addSubview(imageView)
            if let mainframe = self.mainView, size.width > 0, size.height > 0 {
                let minZoom = min(mainframe.bounds.size.width / size.width , mainframe.bounds.size.height / size.height )
                initialZoomScale = minZoom
                scrollView.minimumZoomScale = minZoom
                scrollView.zoomScale = minZoom
            }
        }
        
    }
}

extension ScrollerCollectionViewCell : UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        NotificationCenter.default.post(name: .hideNavigationBar, object: nil)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == initialZoomScale {
            NotificationCenter.default.post(name: .showNavigationBar, object: nil)
        }
    }
}
