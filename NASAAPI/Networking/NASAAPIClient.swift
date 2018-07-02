//
//  NASAAPIClient.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/11/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation
import UIKit

class NasaApiClient {
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    // MARK: - APOD Download Function
    
    /// Get's Astronomy Picture of the Day
    ///
    /// - Parameters:
    ///   - date: The date of which you want the astronomy picture
    ///   - completion: A completion handler that provides the data or an error depending upon the response
    func getAPOD(date: Date, completion: @escaping (APOD?, APIError?) -> Void) {
        let endPoint = NasaApi.apod(date: date)
        let request = endPoint.request
        let task = session.dataTask(with: request) {data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else { completion(nil, .requestFailed); return }
            if httpResponse.statusCode == 200 {
                if let data = data {
                    DispatchQueue.main.async {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        decoder.dateDecodingStrategy = .formatted(formatter)
                        do {
                            let apod = try decoder.decode(APOD.self, from: data)
                            completion(apod, nil)
                        } catch {
                            completion(nil, .jsonParsingFailure)
                        }
                    }
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
            
            if let _ = error {
                completion(nil, .unknownError)
            }
        }
        task.resume()
    }
    
    
    // MARK: - Mars Rover Download Function
    
    /// Get's latest mars rover photos from the rover API
    ///
    /// - Parameters:
    ///   - date: The earth date on which the rover photos were taken only photos from this date will be supplied
    ///   - page: the page number for a multi-page response
    ///   - completion: A completion handler that provides the data or an error depending upon the response
    func getMarsPhotos(date: Date, page: Int, completion: @escaping([Photo]?, APIError?) -> Void) {
        let endPoint = NasaApi.marsRover(date: date, page: page)
        let request = endPoint.request
        let task = session.dataTask(with: request) {data, response, error in
            DispatchQueue.main.async {
                if let _ = error {
                    completion(nil, .unknownError)
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil, .requestFailed)
                    return
                }
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        print(try! JSONSerialization.jsonObject(with: data, options: []))
                        let decoder = JSONDecoder()
                        do {
                            let photosDict = try decoder.decode([String:[Photo]].self, from: data)
                            let photoURLS = photosDict["photos"]!
                            if photoURLS.isEmpty {
                                completion(nil, .noPhotos)
                            } else {
                                completion(photoURLS, nil)
                            }
                        } catch {
                            completion(nil, APIError.jsonParsingFailure)
                        }
                    }
                } else {
                    completion(nil, .responseUnsuccessful)
                }
            }
        }
        task.resume()
    }
    
    
    // MARK: - Earth Image Download Function
    
    /// Get's latest mars rover photos from the rover API
    ///
    /// - Parameters:
    ///   - lat: latitude value
    ///   - long: longitude value
    ///   - date: The date of the picture taken (if nil, returns most recent date)
    ///   - completion: A completion handler that provides the data or an error depending upon the response
    func getEarthImage(lat: Double, long: Double, date: Date?, completion: @escaping (EarthImage?, APIError?) -> Void ) {
        let endpoint = NasaApi.earth(lat: lat, long: long, date: date)
        let request = endpoint.request
        print(request)
        let task = session.dataTask(with: request) {data, response, error in
            if let data = data {
                guard let response = response as? HTTPURLResponse else { completion(nil, .responseUnsuccessful); print("taco"); return }
                if response.statusCode == 200 {
                    let decoder = JSONDecoder()
                    do {
                        let earthImage = try decoder.decode(EarthImage.self, from: data)
                        completion(earthImage, nil)
                    } catch {
                        completion(nil, APIError.jsonParsingFailure)
                    }
                } else {
                    completion(nil, APIError.responseUnsuccessful)
                }
            } else if let _ = error {
                completion(nil, .unknownError)
            }
        }
        task.resume()
        
    }
    
    func getImageFrom(url: URL, completion: @escaping (UIImage?, APIError?) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    let image = UIImage(data: data)
                    completion(image, nil)
                } else if let _ = error {
                    completion(nil, .unknownError)
                }
            }
        }
        task.resume()
    }
    
    
}




