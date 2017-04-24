//
//  ViewController.swift
//  VirtualLondon
//
//  Created by Ginny Pennekamp on 4/23/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var flickrClient = FlickrClient()
    
    var context: NSManagedObjectContext!
    
    let flickrPhotoFetchRequest = NSFetchRequest<FlickrPhoto>(entityName: "FlickrPhoto")
    
    var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add activity indicator
        addActivityIndicator()
        // set up custom flow
        fitCollectionFlowToSize(self.view.frame.size)
        
        // create map
        createMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // access the Core Data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        context = stack.context
        
        // fetch data
        fetchFlickrImages()
        
        // load Images
        loadImages()
    }
    
    // MARK: - Activity Indicator
    
    func addActivityIndicator() {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:100, height:100)) as UIActivityIndicatorView
        
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        
        self.view.addSubview(activityIndicator)
    }
    
    // MARK: - Collection View Flow
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // set up custom flow
        if flowLayout != nil {
            fitCollectionFlowToSize(size)
        }
    }
    
    func fitCollectionFlowToSize(_ size: CGSize) {
        // determine the number of and spacing between collection items
        let space: CGFloat = 3.0
        // adjust dimension to width and height of screen
        let dimension = size.width >= size.height ? (size.width - (5*space))/5.0 : (size.width - (2*space))/3.0
        // set up custom flow
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // returns the number of flickr photos
        return  PhotoAlbum.albumImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        
        let photo = PhotoAlbum.albumImages[(indexPath as NSIndexPath).row]
        cell.imageView?.image = photo
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // delete the photo from core data and the view
        let selectedFlickrPhoto = PhotoAlbum.albumFlickrPhotos[(indexPath as NSIndexPath).row]
        self.context.delete(selectedFlickrPhoto)
        PhotoAlbum.albumFlickrPhotos.remove(at: (indexPath as NSIndexPath).row)
        
        // remove from view
        PhotoAlbum.albumImages.remove(at: (indexPath as NSIndexPath).row)
        // reload view
        self.collectionView.reloadData()

        // TODO: replace it
    }
    
    // MARK: - Create Map
    
    func createMap() {
        // set region
        let latitude: CLLocationDegrees = London.latitude
        let longitude: CLLocationDegrees = London.longitude
        let latDelta: CLLocationDegrees = 0.25
        let lonDelta: CLLocationDegrees = 0.25
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        
        // add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK: - Fetch Images from Core Data
    
    func fetchFlickrImages() {
        do {
            // fetch photos
            let allFlickrPhotos = try self.context.fetch(flickrPhotoFetchRequest)
            // add photos to view
            print("All photos count: \(allFlickrPhotos.count)")
            for photo in allFlickrPhotos {
                // add pin to PhotoAlbum.albumFlickerPhotos
                PhotoAlbum.albumFlickrPhotos.append(photo)
                // extract data, add to PhotoAlbumModel
                if let image = UIImage(data: photo.imageData! as Data) {
                    PhotoAlbum.albumImages.append(image)
                }
            }
        } catch {
            fatalError("Failed to fetch pins: \(error)")
        }
    }

    // MARK: - Determine How To Load Images
    
    private func loadImages() {
        if PhotoAlbum.albumImages.count == 0 {
            fetchImages()
        } 
    }
    
    // MARK: - Fetch Images from Flickr

    private func fetchImages() {
        
        self.activityIndicator.startAnimating()
        print("Starting request for photos...")
        
        flickrClient.getImagesFromFlickrBySearch() { (data: AnyObject?, error: NSError?) -> Void in
            
            if error != nil {
                DispatchQueue.main.async {
                    print("There was an error getting the images: \(String(describing: error))")
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        if isInternetAvailable() == false {
                            Alerts.displayInternetConnectionAlert(from: self)
                        } else {
                            Alerts.displayStandardAlert(from: self)
                        }
                    }
                }
                
            } else {
                
                print("JSON parsed. Ready to extract images.")
                
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = data?[FlickrRequest.FlickrResponseKeys.Status] as? String, stat == FlickrRequest.FlickrResponseValues.OKStatus else {
                    print("Flickr API returned an error. See error code and message in \(String(describing: data))")
                    return
                }
                
                /* GUARD: Is the "photos" key in our result? */
                guard let photosDictionary = data?[FlickrRequest.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    print("Cannot find key '\(FlickrRequest.FlickrResponseKeys.Photos)' in \(String(describing: data))")
                    return
                }
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[FlickrRequest.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    print("Cannot find key '\(FlickrRequest.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }
                
                self.extractImages(from: photosArray) { (success: Bool) -> Void in
                    if success {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.collectionView.reloadData()
                        }
                    } else {
                        // TODO: Display alert
                        print("Photos could not be extracted.")
                    }
                }
            }
        }
    }
    
    // MARK: - Extract Images from API Call
    
    func extractImages(from photosArray: [[String: AnyObject]], completionHandler: @escaping (Bool)->Void) {
        
        if photosArray.count == 0 {
            // TODO: Add alert no photos found
            print("No Photos Found. Search Again.")
            return
            
        } else {
            for photoDict in photosArray {
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDict[FlickrRequest.FlickrResponseKeys.MediumURL] as? String else {
                    print("Cannot find key \(FlickrRequest.FlickrResponseKeys.MediumURL) in \(photoDict)")
                    completionHandler(false)
                    return
                }
                // if an image exists at the url, open image and add to photos
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    // save Data to a FlickerPhoto object
                    self.addFlickrPhotoToDatabase(imageData: imageData)
                    // extract the image and add it to photo album
                    if let image = UIImage(data: imageData) {
                        PhotoAlbum.albumImages.append(image)
                    }
                }
                // send success or fail message to reload collection view
                completionHandler(true)
            }
        }
    }
    
    // MARK: - Add FlickrPhoto to Database
    
    func addFlickrPhotoToDatabase(imageData: Data) {
        let newFlickrPhoto = FlickrPhoto(imageData: imageData, context: self.context)
        // add photo to PhotoAlbum.albumFlickerPhotos
        PhotoAlbum.albumFlickrPhotos.append(newFlickrPhoto)
        print("Created new photo: \(String(describing: newFlickrPhoto))")
    }


    @IBAction func importNewPhotos(_ sender: Any) {
        print("Importing new photos...")
        // delete all from database
        do {
            // fetch photos
            let allFlickrPhotos = try self.context.fetch(flickrPhotoFetchRequest)
            // delete all photos
            for photo in allFlickrPhotos {
                self.context.delete(photo)
            }
            // remove all from album
            PhotoAlbum.albumFlickrPhotos.removeAll()
            PhotoAlbum.albumImages.removeAll()
        } catch {
            fatalError("Failed to fetch pins: \(error)")
        }
        // fetch new photos
        loadImages()
    }

}

