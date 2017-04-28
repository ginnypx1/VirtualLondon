//
//  FlickrConvienence.swift
//  VirtualLondon
//
//  Created by Ginny Pennekamp on 4/23/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {
    
    // MARK: - Parse JSON Data
    
    func parseJSONDataWithCompletionHandler(_ data: Data, completionHandlerForData: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        print("3. Parsing JSON...")
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForData(nil, NSError(domain: "parseJSONDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        OperationQueue.main.addOperation {
            completionHandlerForData(parsedResult, nil)
        }
    }
    
    // MARK: - Extract All Photos from JSON
    
    func extractPhotos(fromJSONDictionary jsonDictionary: AnyObject) -> [Photo] {
        print("4. Extracting list of all photos from JSON")
        
        var allPhotos = [Photo]()

        guard let photos = jsonDictionary[FlickrRequest.FlickrResponseKeys.Photos] as? [String: Any],
              let photosArray = photos[FlickrRequest.FlickrResponseKeys.Photo] as? [[String: Any]] else {
                print("The proper keys are not in the provided JSON array.")
                return []
        }
        
        // TODO: I am auto using page on here but might like to use a different page
        // print("photos dict: \(photos)")
        
        for photoDict in photosArray {
            if let photo = self.createPhoto(from: photoDict) {
                allPhotos.append(photo)
            }
        }
        return allPhotos
    }
    
    // MARK: - Extract Image from Single Photo
    
    private func createPhoto(from jsonDict: [String: Any]) -> Photo? {
        
        guard let photoURLString = jsonDict["url_m"] as? String,
              let url = URL(string: photoURLString) else {
                return nil
        }
        // TODO: Instead of returning photo, save to core data
        return Photo(remoteURL: url)
    }
    
    
}
