//
//  PhotoModel.swift
//  VirtualLondon
//
//  Created by Ginny Pennekamp on 4/26/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import Foundation

class Photo {
    let remoteURL: URL
    
    init(remoteURL: URL) {
        self.remoteURL = remoteURL
    }
}

struct PhotoAlbum {
    
    static var albumPhotos: [Photo] = []
    
}

extension Photo: Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        // Two Photos are the same if they have the same photoID
        return lhs.remoteURL == rhs.remoteURL
    }
}
