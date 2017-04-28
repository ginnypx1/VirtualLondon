//
//  FlickrClient.swift
//  VirtualLondon
//
//  Created by Ginny Pennekamp on 4/23/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient : NSObject {
    
    // MARK: - Properties
    
    var session = URLSession.shared
    var flickrRequest = FlickrRequest()
    
    // MARK: - Fetch all Images with Latitude and Longitude
    
    func fetchImagesWithLatitudeAndLongitude(completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        print("2. Building request for all photos...")
        
        /* Set the Parameters */
        var methodParameters: [String: Any] = [
            FlickrRequest.FlickrParameterKeys.Latitude: FlickrRequest.FlickrParameterValues.DesiredLatitude,
            FlickrRequest.FlickrParameterKeys.Longitude: FlickrRequest.FlickrParameterValues.DesiredLongitude,
            FlickrRequest.FlickrParameterKeys.ResultsPerPage: FlickrRequest.FlickrParameterValues.DesiredNumberOfResults]
        
        /* Build the URL */
        var getRequestURL = flickrRequest.buildURL(fromParameters: methodParameters)
        
        /* Configure the request */
        let request = URLRequest(url: getRequestURL)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "getImagesWithLatitudeAndLongitude", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            /* Parse the Parse data and use the data (happens in completion handler) */
            self.parseJSONDataWithCompletionHandler(data, completionHandlerForData: completionHandler)
        }
        task.resume()
    }
    
    // MARK: - Fetch single image from URL
    
    func fetchImage(for photo: Photo, completionHandler: @escaping (_ data: Data?) -> Void) {
        
        /* Build the URL */
        let photoURL = photo.remoteURL
        
        /* Configure the request */
        let request = URLRequest(url: photoURL)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            OperationQueue.main.addOperation {
                completionHandler(data)
            }
        }
        task.resume()
    }
    
}
