//
//  EndPoint.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/11/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation

protocol EndPoint {
    var base: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension EndPoint {
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        components.queryItems = [URLQueryItem(name: "api_key", value: "jOjcAvzsXhm1dOYZCqZ069n4j0zHOXKEiUTmenhp")]
        components.queryItems?.append(contentsOf: queryItems)
        
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}

enum NasaApi {
    case apod(date: Date)
    case marsRover(date: Date, page: Int)
    case earth(lat: Double, long: Double, date: Date?)
}

extension NasaApi: EndPoint {
    var base: String {
        return "https://api.nasa.gov"
    }
    
    var path: String {
        switch self {
        case .apod: return "/planetary/apod"
        case .marsRover: return "/mars-photos/api/v1/rovers/curiosity/photos/"
        case .earth: return "/planetary/earth/imagery/"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .apod(let date):
            print(date.toString(withFormat: "yyyy-MM-dd"))
            var result = [URLQueryItem]()
            let date = URLQueryItem(name: "date", value: date.toString(withFormat: "yyyy-MM-dd"))
            let getHD = URLQueryItem(name: "hd", value: "true")
            result.append(getHD)
            result.append(date)
            return result
        case .marsRover(let date, let page):
            var result = [URLQueryItem]()
            let martianDate = URLQueryItem(name: "earth_date", value: "\(date.toString(withFormat: "yyyy-MM-dd"))")
            let page = URLQueryItem(name: "page", value: "\(page)")
            result.append(martianDate)
            result.append(page)
            return result
        case .earth(let lat, let long, let date):
            var result = [URLQueryItem]()
            if let date = date {
                let date = URLQueryItem(name: "date", value: date.toString(withFormat: "yyyy-MM-dd"))
                result.append(date)
            }
            let long = URLQueryItem(name: "lon", value: "\(long)")
            let lat = URLQueryItem(name: "lat", value: "\(lat)")
            result.append(long)
            result.append(lat)
            return result
        }
    }
    
    
}


enum Rover {
    case curiosity
    case opportunity
    case spirit
}




















