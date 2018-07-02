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
        
        let expectation = XCTestExpectation(description: "APOD was downloaded successfully")
        
        client.getAPOD(date: Date()) {apod, error in
            XCTAssert(apod != nil, "apod was unexpectedly nil")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDownloadMarsRover() {
        
        let expectation = XCTestExpectation(description: "Mars Photos were downloaded successfully")
        
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        client.getMarsPhotos(date: date, page: 1) { photos, error in
            XCTAssert(photos != nil, "Photos were unexpectedly nil")
            if let photos = photos {
                XCTAssert(!photos.isEmpty, "photos were unexpectedly empty")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEarthImagery() {
        
        let expectation = XCTestExpectation(description: "Earth Image was downloaded successfully")
        
        client.getEarthImage(lat: 1.5, long: 100.75, date: nil) { earthImage, error in
            XCTAssert(earthImage != nil, "Earth Image was unexpectedly nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAPODParse() {
        let json = """
        {
          "date": "2018-07-02",
          "explanation": "Behold one of the most photogenic regions of the night sky, captured impressively.  Featured, the band of our Milky Way Galaxy runs diagonally along the far left, while the colorful Rho Ophiuchus region including the bright orange star Antares is visible just right of center, and the nebula Sharpless 1 (Sh2-1) appears on the far right. Visible in front of the Milk Way band are several famous nebulas including the Eagle Nebula (M16), the Trifid Nebula (M20), and the Lagoon Nebula (M8).  Other notable nebulas include the Pipe and Blue Horsehead.  In general, red emanates from nebulas glowing in the light of exited hydrogen gas, while blue marks interstellar dust preferentially reflecting the light of bright young stars.  Thick dust appears otherwise dark brown.  Large balls of stars visible include the globular clusters M4, M9, M19, M28, and M80, each marked on the  annotated companion image.  This extremely wide field -- about 50 degrees across -- spans the constellations of Sagittarius is on the lower left, Serpens on the upper left, Ophiuchus across the middle, and Scorpius on the right.  It took over 100 hours of sky imaging, combined with meticulous planning and digital processing, to create this image.",
          "hdurl": "https://apod.nasa.gov/apod/image/1807/MwPastAntares_Andreo_2048.jpg",
          "media_type": "image",
          "service_version": "v1",
          "title": "From the Galactic Plane through Antares",
          "url": "https://apod.nasa.gov/apod/image/1807/MwPastAntares_Andreo_1080.jpg"
        }
        """.data(using: .utf8)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(formatter)
        let apod = try? decoder.decode(APOD.self, from: json)
        XCTAssert(apod != nil, "APOD was unexpectedly nil")
    }
    
    
    func testEarthImageParse() {
        let json = """
        {
            "cloud_score": 0.03926652301686606,
            "date": "2014-02-04T03:30:01",
            "id": "LC8_L1T_TOA/LC81270592014035LGN00",
            "resource": {
                "dataset": "LC8_L1T_TOA",
                "planet": "earth"
            },
            "service_version": "v1",
            "url": "https://earthengine.googleapis.com/api/thumb?thumbid=af25578e2b5b9d934c77f97fd67bfbe0&token=8eb2028fe24fc8830546e0abf17a2f75"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let earthImage = try? decoder.decode(EarthImage.self, from: json)
        XCTAssert(earthImage != nil, "Parsing Failed")
    }
    
    func testMarsRoverParse() {
        let json = """
                {
            "photos": [
                {
                    "id": 102693,
                    "sol": 1000,
                    "camera": {
                        "id": 20,
                        "name": "FHAZ",
                        "rover_id": 5,
                        "full_name": "Front Hazard Avoidance Camera"
                    },
                    "img_src": "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/01000/opgs/edr/fcam/FLB_486265257EDR_F0481570FHAZ00323M_.JPG",
                    "earth_date": "2015-05-30",
                    "rover": {
                        "id": 5,
                        "name": "Curiosity",
                        "landing_date": "2012-08-06",
                        "launch_date": "2011-11-26",
                        "status": "active",
                        "max_sol": 2098,
                        "max_date": "2018-07-01",
                        "total_photos": 338424,
                        "cameras": [
                            {
                                "name": "FHAZ",
                                "full_name": "Front Hazard Avoidance Camera"
                            },
                            {
                                "name": "NAVCAM",
                                "full_name": "Navigation Camera"
                            },
                            {
                                "name": "MAST",
                                "full_name": "Mast Camera"
                            },
                            {
                                "name": "CHEMCAM",
                                "full_name": "Chemistry and Camera Complex"
                            },
                            {
                                "name": "MAHLI",
                                "full_name": "Mars Hand Lens Imager"
                            },
                            {
                                "name": "MARDI",
                                "full_name": "Mars Descent Imager"
                            },
                            {
                                "name": "RHAZ",
                                "full_name": "Rear Hazard Avoidance Camera"
                            }
                        ]
                    }
                },
                {
                    "id": 102694,
                    "sol": 1000,
                    "camera": {
                        "id": 20,
                        "name": "FHAZ",
                        "rover_id": 5,
                        "full_name": "Front Hazard Avoidance Camera"
                    },
                    "img_src": "http://mars.jpl.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/01000/opgs/edr/fcam/FRB_486265257EDR_F0481570FHAZ00323M_.JPG",
                    "earth_date": "2015-05-30",
                    "rover": {
                        "id": 5,
                        "name": "Curiosity",
                        "landing_date": "2012-08-06",
                        "launch_date": "2011-11-26",
                        "status": "active",
                        "max_sol": 2098,
                        "max_date": "2018-07-01",
                        "total_photos": 338424,
                        "cameras": [
                            {
                                "name": "FHAZ",
                                "full_name": "Front Hazard Avoidance Camera"
                            },
                            {
                                "name": "NAVCAM",
                                "full_name": "Navigation Camera"
                            },
                            {
                                "name": "MAST",
                                "full_name": "Mast Camera"
                            },
                            {
                                "name": "CHEMCAM",
                                "full_name": "Chemistry and Camera Complex"
                            },
                            {
                                "name": "MAHLI",
                                "full_name": "Mars Hand Lens Imager"
                            },
                            {
                                "name": "MARDI",
                                "full_name": "Mars Descent Imager"
                            },
                            {
                                "name": "RHAZ",
                                "full_name": "Rear Hazard Avoidance Camera"
                            }
                        ]
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let marsImagesDict = try? decoder.decode([String:[Photo]].self, from: json)
        let marsImages = marsImagesDict?["photos"]
        
        XCTAssert(marsImages != nil, "Mars Images were unexpectedly nil")
    }
    
}
