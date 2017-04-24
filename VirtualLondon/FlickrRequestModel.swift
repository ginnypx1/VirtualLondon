//
//  FlickrRequestModel.swift
//  VirtualLondon
//
//  Created by Ginny Pennekamp on 4/23/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import Foundation

struct FlickrRequest {
    
    // MARK: - Properties
    
    struct FlickrURL {
        static let Scheme: String = "https"
        static let Host: String = "api.flickr.com"
        static let Path: String = "/services/rest"
    }
    
    struct FlickrParameterKeys {
        static let Method: String = "method"
        static let APIKey: String = "api_key"
        static let Extras: String = "extras"
        static let Format: String = "format"
        static let NoJSONCallback: String = "nojsoncallback"
        static let SafeSearch: String = "safe_search"
        static let Latitude: String = "lat"
        static let Longitude: String = "lon"
        static let ResultsPerPage: String = "per_page"
    }
    
    struct FlickrParameterValues {
        static let APIKey: String = YOUR_API_KEY
        static let SearchMethod: String = "flickr.photos.search"
        static let ResponseFormat: String = "json"
        static let DisableJSONCallback: String = "1" /* 1 means "yes" */
        static let MediumURL: String = "url_m"
        static let UseSafeSearch = "1"
        static let DesiredLatitude = London.latitude
        static let DesiredLongitude = London.longitude
        static let DesiredNumberOfResults = 21
    }

    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
    }
    
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    func buildURLFromParameters(_ parameters: [String: Any]) -> URL {
        var components = URLComponents()
        components.scheme = FlickrURL.Scheme
        components.host = FlickrURL.Host
        components.path = FlickrURL.Path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print("URL request is: \(components.url!)")
        return components.url!
    }
}
