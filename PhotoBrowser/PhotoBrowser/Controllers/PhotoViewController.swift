//
//  ViewController.swift
//  PhotoBrowser
//
//  Created by Himalaya Rajput on 06/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
class PhotoViewController: UIViewController {
    //MARK: Variables
    private var imageArray = PhotoManager.shared.photos
    var currentIndex = 0
    private var backgroundColor: UIColor = .white {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    private var imagePicker = UIImagePickerController()
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    
    override func viewWillLayoutSubviews() {
        if scrollView != nil {scrollView.removeFromSuperview()}
        setUpScrollView()
        imageView = UIImageView()
        setImage(for: currentIndex)
        recenterImage()
        setGestures()
    }
    
    //MARK: Configuring ScrollView
    private func setUpScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    //MARK: Configuring imageView
    private func setImage(for index: Int) {
        if imageView != nil { imageView.removeFromSuperview() }
        imageView.image = imageArray[index]
        imageView.sizeToFit()
        scrollView.contentSize = imageView.bounds.size
        self.scrollView.addSubview(self.imageView)
        setZoomScale(for: scrollView.bounds.size)
    }
    
    //MARK: Calculating Zoom scale
    private func setZoomScale(for scrollViewsize: CGSize) {
        let imageViewSize = imageView.bounds.size
        let widthScale = scrollViewsize.width / imageViewSize.width
        let heightScale = scrollViewsize.height / imageViewSize.height
        let minimumScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minimumScale
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = minimumScale
    }
    
    //MARK: Centering the image
    private func recenterImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        validateImageView(size: imageViewSize)
        let horizontalSpace = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2.0 : 0
        let verticalSpace = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2.0 : 0
        var extraTopSpace: CGFloat = 0
        if let navigationBar = navigationController?.navigationBar {
            let height = navigationBar.bounds.size.height
            navigationBar.isHidden ? (extraTopSpace = 0 ): (extraTopSpace = height)
        }
        var topSpace = verticalSpace - extraTopSpace
        if topSpace < 0 {
            topSpace = verticalSpace
        }
        scrollView.contentInset = UIEdgeInsets(top: topSpace , left: horizontalSpace, bottom: verticalSpace , right: horizontalSpace)
    }
    
    private func validateImageView(size imageViewSize: CGSize) {
        let viewSize = view.bounds.size
        if imageViewSize.width > viewSize.width {
            imageView.frame.size.width = viewSize.width
        }
        if imageViewSize.height > viewSize.height {
            imageView.frame.size.height = viewSize.height
        }
    }
    
    //MARK: Adding Gestures
    private func setGestures() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc private func leftSwipe(_ gesture: UISwipeGestureRecognizer) {
        (currentIndex < imageArray.count - 1) ? (currentIndex += 1) : (currentIndex = 0)
        setImage(for: currentIndex)
        setZoomScale(for: scrollView.bounds.size)
        recenterImage()
    }
    
    @objc private func rightSwipe(_ gesture: UISwipeGestureRecognizer) {
        (currentIndex < 1) ? (currentIndex = imageArray.count - 1) : (currentIndex -= 1)
        setImage(for: currentIndex)
        setZoomScale(for: scrollView.bounds.size)
        recenterImage()
    }
}

//MARK: Extensions
extension PhotoViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenterImage()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
   
}
