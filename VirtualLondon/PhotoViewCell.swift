//
//  PhotoViewCell.swift
//  VirtualLondon
//
//  Created by Ginny Pennekamp on 4/24/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        update(with: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        update(with: nil)
    }
    
    func update(with image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        update()
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        update()
//    }
//    
//    func update() {
//        if imageView.image == nil {
//            spinner.startAnimating()
//        } else {
//            spinner.stopAnimating()
//        }
//    }
    
}
