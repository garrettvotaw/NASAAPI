//
//  RoverCell.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/20/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit

class RoverCell: UICollectionViewCell {

    let client = NasaApiClient()
    
    @IBOutlet weak var roverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.cornerRadius = 25.0
        self.contentView.layer.masksToBounds = true
    }


}
