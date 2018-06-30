//
//  Photo.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/19/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation
import UIKit

enum ImageState {
    case placeHolder
    case downloaded
    case failed
}

class Photo: Decodable {
    let imageURL: URL
    var image: UIImage?
    var imageState = ImageState.placeHolder
    
    enum CodingKeys: String, CodingKey {
        case imgSrc = "img_src"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageURL = try container.decode(URL.self, forKey: .imgSrc)
    }
}
