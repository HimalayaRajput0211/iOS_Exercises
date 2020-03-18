//
//  Picture.swift
//  PhotoBrowser
//
//  Created by Himalaya Rajput on 12/03/20.
//  Copyright © 2020 Himalaya Rajput. All rights reserved.
//

import Foundation
import UIKit
class PhotoManager {
    private(set) var photos = [UIImage]()
    static let shared = PhotoManager()
    private init() {}
    func removeAll() {
        photos.removeAll()
    }
    private func addPhoto(_ photo: UIImage) {
        photos.append(photo)
    }
    
    func downloadAllImages(from data: NSArray, completion: @escaping () -> Void ) {
        var count = 0
        let dispatchGroup = DispatchGroup()
        data.forEach { dataItems in
            if let dataItemsDictionary = dataItems as? NSDictionary {
                if let imageArray = dataItemsDictionary["images"] as? NSArray {
                    if let imageDict = imageArray.firstObject as? NSDictionary {
                        if let imageSource = imageDict["source"] as? String {
                            if let url = URL(string: imageSource) {
                                dispatchGroup.enter()
                                downloadPhoto(url: url) { result in
                                    switch result {
                                    case .success(let photo):
                                        count += 1
                                        self.addPhoto(photo)
                                        if count % 10 == 0 {
                                            DispatchQueue.main.async {
                                                completion()
                                            }
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    private func downloadPhoto(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data) else {
                    completion(.failure(error!))
                    return }
            completion(.success(image))
        }.resume()
    }
}
