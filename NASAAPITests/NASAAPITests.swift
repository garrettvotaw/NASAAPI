//
//  NASAAPITests.swift
//  NASAAPITests
//
//  Created by Garrett Votaw on 6/11/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import XCTest
@testable import NASAAPI

class NASAAPITests: XCTestCase {
    
    let client = NasaApiClient()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDownloadAPOD() {
        client.getAPOD(date: Date()) {apod, error in
            XCTAssert(apod != nil, "apod was unexpectedly nil")
        }
    }
    
    func testDownloadMarsRover() {
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        client.getMarsPhotos(date: date, page: 1) { photos, error in
            XCTAssert(photos != nil, "Photos were unexpectedly nil")
            if let photos = photos {
                XCTAssert(!photos.isEmpty, "photos were unexpectedly empty")
            }
        }
    }
    
    func testEarthImagery() {
        client.getEarthImage(lat: 1.5, long: 100.75, date: nil) { earthImage, error in
            XCTAssert(earthImage != nil, "Earth Image was unexpectedly nil")
        }
    }
    
}
