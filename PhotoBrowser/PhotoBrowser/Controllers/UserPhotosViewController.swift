//
//  UserPhotosViewController.swift
//  PhotoBrowser
//
//  Created by Himalaya Rajput on 12/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class UserPhotosViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    private var images = PhotoManager.shared.photos
    private var spacing: CGFloat = 5.0
    private var buttonWidth: CGFloat = Constants.buttonWidth
    private var buttonHeight: CGFloat = Constants.buttonHeight
    private var requiredPermission: String = "user_photos"
    private var controllerTitle = "User Photos"
    private var loginButton:FBLoginButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            loginButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = controllerTitle
        layoutCollectionView()
        setupLoginbutton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutLoginButton()
    }
    
    private func layoutLoginButton() {
        (AccessToken.current != nil) ? (translateLoginButton(loginButton)) : (loginButton.center = view.center)
    }
    
    private func setupLoginbutton() {
        loginButton = FBLoginButton(permissions: [ .publicProfile,.userPhotos, .email])
        loginButton.frame.size = CGSize(width: buttonWidth, height: buttonHeight)
        loginButton.delegate = self
        navigationController?.view.addSubview(loginButton)
        configureLoginButton()
    }
    
    private func configureLoginButton() {
        if AccessToken.current != nil, loginButton.permissions.contains(requiredPermission) {
             fetchListOfUserPhotos()
        } else {
            collectionView.alpha = 0
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    private func layoutCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView.collectionViewLayout = layout
    }
    
    private func fetchListOfUserPhotos() {
        let graphPath = "me/photos/uploaded"
        let parameters = [
            "fields": "images"
        ]
        let graphRequest = GraphRequest.init(graphPath: graphPath, parameters: parameters)
        graphRequest.start { (connection, response, error) in
            if let responseDict = response as? NSDictionary {
                if let data = responseDict["data"] as? NSArray {
                    PhotoManager.shared.downloadAllImages(from: data) { [weak self] in
                        guard let self = self else { return }
                        self.images = PhotoManager.shared.photos
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension UserPhotosViewController:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CustomCollectionViewCell {
            cell.imageView.image = images[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ItemSize()
    }
    
    private func ItemSize() -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        var numberOfItemPerRow: CGFloat!
        if screenWidth < Constants.comparingWidth {
            numberOfItemPerRow = 3
        } else if screenWidth == Constants.comparingWidth {
            numberOfItemPerRow = 4
        } else {
            numberOfItemPerRow = 5
        }
        let totalSpacing = (numberOfItemPerRow + 1) * spacing
        if let collectionView = self.collectionView {
            let width = (collectionView.bounds.width - totalSpacing) / numberOfItemPerRow
            return CGSize(width: width, height: width)
        } else {
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loginButton.isHidden = true
        if let nextVC = storyboard?.instantiateViewController(withIdentifier: PhotoScrollerViewController.identifier) as? PhotoScrollerViewController {
            nextVC.selectedRow = indexPath.row
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

extension UserPhotosViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if result?.token != nil, loginButton.permissions.contains(requiredPermission)  {
            translateLoginButton(loginButton)
            fetchListOfUserPhotos()
        }
    }
    
    private func translateLoginButton(_ button: FBLoginButton) {
        var x: CGFloat = view.bounds.width - (buttonWidth + 20)
        var y: CGFloat = 50
        var trailingPadding: CGFloat = 5.0
        if let navigationBar = navigationController?.navigationBar {
            let barHeight = navigationBar.bounds.height
            let barWidth = navigationBar.bounds.width
            if buttonHeight > barHeight {
               buttonHeight = barHeight - 5.0
                trailingPadding = view.safeAreaInsets.right
                if trailingPadding == 0 {
                    trailingPadding = 5.0
                }
            } else {
                buttonHeight = Constants.buttonHeight
            }
            button.frame.size.height = buttonHeight
            let remainingSpace = barHeight - buttonHeight
            x = barWidth - (buttonWidth + trailingPadding)
            y = navigationController!.view.safeAreaInsets.top + remainingSpace/2
        }
        UIView.animate(withDuration: 0.5) { 
            button.frame.origin = CGPoint(x: x, y: y)
            self.collectionView.alpha = 1
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        PhotoManager.shared.removeAll()
        images = PhotoManager.shared.photos
        collectionView.reloadData()
    }
}
extension UserPhotosViewController {
    struct Constants {
          static let buttonWidth: CGFloat = 120.0
          static let buttonHeight: CGFloat = 35.0
          static let comparingWidth: CGFloat = 768.0
    }
}
