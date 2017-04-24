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
    
    func parseJSONDataWithCompletionHandler(_ data: Data, completionHandlerForData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        print("Parsing JSON...")
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForData(nil, NSError(domain: "parseJSONDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForData(parsedResult, nil)
    }
    
}
