//
//  PendingOperations.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/26/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation

class PendingOperations {
    var downloadsInProgress = [IndexPath:Operation]()
    let downloadQueue = OperationQueue()
}
