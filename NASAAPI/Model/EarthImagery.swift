//
//  EarthImagery.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/29/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation
import UIKit

struct EarthImage: Decodable{
    var image: UIImage?
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(URL.self, forKey: .url)
    }
    
}
