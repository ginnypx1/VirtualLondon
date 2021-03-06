//
//  ActivityIndicatorConfiguration.swift
//  VirtualLondon
//
//  Created by Ginny Pennekamp on 4/27/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import UIKit

extension ViewController {
    
    // MARK: - Activity Indicator
    
    func addActivityIndicator() {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:100, height:100)) as UIActivityIndicatorView
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }
}
