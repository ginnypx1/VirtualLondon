//
//  FlickrPhoto+CoreDataClass.swift
//  VirtualLondon
//
//  Created by Ginny Pennekamp on 4/23/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import Foundation
import CoreData


public class FlickrPhoto: NSManagedObject {

    convenience init(imageData: Data, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "FlickrPhoto", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageData = imageData as NSData
        } else {
            fatalError("Unable to find FlickrPhoto Entity!")
        }
    }
}
