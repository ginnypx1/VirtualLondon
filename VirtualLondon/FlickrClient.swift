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
    
    // MARK: Properties
    
    var session = URLSession.shared
    var flickrRequest = FlickrRequest()
    
    // MARK: Flickr API
    
    func getImagesFromFlickrBySearch(completionHandlerForGetImages: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        /* Set the Parameters */
        var methodParameters: [String: Any] = [
            FlickrRequest.FlickrParameterKeys.SafeSearch: FlickrRequest.FlickrParameterValues.UseSafeSearch,
            FlickrRequest.FlickrParameterKeys.Extras: FlickrRequest.FlickrParameterValues.MediumURL,
            FlickrRequest.FlickrParameterKeys.APIKey: FlickrRequest.FlickrParameterValues.APIKey,
            FlickrRequest.FlickrParameterKeys.Method: FlickrRequest.FlickrParameterValues.SearchMethod,
            FlickrRequest.FlickrParameterKeys.Format: FlickrRequest.FlickrParameterValues.ResponseFormat,
            FlickrRequest.FlickrParameterKeys.NoJSONCallback: FlickrRequest.FlickrParameterValues.DisableJSONCallback,
            FlickrRequest.FlickrParameterKeys.Latitude: FlickrRequest.FlickrParameterValues.DesiredLatitude,
            FlickrRequest.FlickrParameterKeys.Longitude: FlickrRequest.FlickrParameterValues.DesiredLongitude,
            FlickrRequest.FlickrParameterKeys.ResultsPerPage: FlickrRequest.FlickrParameterValues.DesiredNumberOfResults]
        
         /* Build the URL */
        var getRequestURL = flickrRequest.buildURLFromParameters(methodParameters)
        
        /* Configure the request */
        let request = NSMutableURLRequest(url: getRequestURL)
        print("Requesting photos...")
        
        // create network request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetImages(nil, NSError(domain: "getImagesFromFlickrBySearch", code: 1, userInfo: userInfo))
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
            self.parseJSONDataWithCompletionHandler(data, completionHandlerForData: completionHandlerForGetImages)
        }
        
        /* Start the request */
        task.resume()
    }
    
}
