//
//  ImageDownloader.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/22/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader: Operation {
    
    let photo: Photo

    init(photo: Photo) {
        self.photo = photo
        super.init()
    }
    
    override func main() {
        if isCancelled { return }
        do {
            let imageData = try Data(contentsOf: photo.imageURL)
            if isCancelled { return }
            if imageData.count > 0 {
                photo.image = UIImage(data: imageData)
                photo.imageState = .downloaded
            } else {
                photo.imageState = .failed
            }
        } catch {
            print(error)
        }
    }
    
}
