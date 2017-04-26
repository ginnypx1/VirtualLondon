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

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIButton!
    
    // MARK: - Properties
    
    // API call
    var flickrClient = FlickrClient()

    // fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController<FlickrPhoto> = { () -> NSFetchedResultsController<FlickrPhoto> in
        let fetchRequest = NSFetchRequest<FlickrPhoto>(entityName: "FlickrPhoto")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    var sharedContext: NSManagedObjectContext!
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // activity indicator
    var activityIndicator: UIActivityIndicatorView!
    
    var isEditingPhotoAlbum: Bool = false
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add activity indicator
        addActivityIndicator()
        // set up custom flow
        fitCollectionFlowToSize(self.view.frame.size)
        
        // create map
        createMap()
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        sharedContext = stack.context
        
        // Start the fetched results controller
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing initial fetch")
        }

        
    }
    
    // MARK: - Check for fetched images
    
    func checkForStoredImages() {
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
    
    // MARK: - Configure Collection Button
    
    func configureButton() {
        if isEditingPhotoAlbum {
            collectionButton.setTitle("Remove Selected Pictures",for: .normal)
        } else {
            collectionButton.setTitle("New Collection",for: .normal)
        }
    }
    
    // MARK: - Collection View
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        print("number Of Cells: \(sectionInfo.numberOfObjects)")
        
        // check to see if images need to be downloaded
        if sectionInfo.numberOfObjects == 0 {
            fetchImages()
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func configureCell(_ cell: PhotoViewCell, atIndexPath indexPath: IndexPath) {
        let flickrPhoto = self.fetchedResultsController.object(at: indexPath)

        let photo = UIImage(data: flickrPhoto.imageData! as Data)
        cell.imageView?.image = photo
        
        // If the cell is "selected", it is grayed out, or marked for deletion
        if let _ = selectedIndexes.index(of: indexPath) {
            cell.imageView.alpha = 0.5
            self.isEditingPhotoAlbum = true
        } else {
            cell.imageView.alpha = 1.0
            self.isEditingPhotoAlbum = false
        }
        configureButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("in collectionView(_:didSelectItemAtIndexPath)")
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoViewCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        // Then reconfigure the cell
        configureCell(cell, atIndexPath: indexPath)
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
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            print("Insert an item")
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            print("Delete an item")
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            print("Update an item.")
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
            //default:
            //break
        }
    }
    
    // This method is invoked after all of the changed objects in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }

    // MARK: - Fetch Images from Flickr

    private func fetchImages() {
        
        self.activityIndicator.startAnimating()
        self.collectionButton.isEnabled = false
        
        print("1. Starting request for photos...")
        
        flickrClient.fetchImagesWithLatitudeAndLongitude() { (data: AnyObject?, error: NSError?) -> Void in
            
            if error != nil {
                print("There was an error getting the images: \(String(describing: error))")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.collectionButton.isEnabled = true
                    if isInternetAvailable() == false {
                        Alerts.displayInternetConnectionAlert(from: self)
                    } else {
                        Alerts.displayStandardAlert(from: self)
                    }
                }
                
            } else {
                guard let data = data else {
                    print("No data was returned.")
                    return
                }
                let photos = self.flickrClient.extractPhotos(fromJSONDictionary: data)
                if !photos.isEmpty {
                    print("There were \(photos.count) photos returned.")
                    // for photo in photos, fetch image data, save to core data
                    for photo in photos {
                        self.fetchSingleImage(for: photo)
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.collectionButton.isEnabled = true
                    }
                } else {
                    print("No photos were returned.")
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.collectionButton.isEnabled = true
                    }
                }
                
            }
        }
    }
    
    func fetchSingleImage(for photo: Photo) {
        
        self.flickrClient.fetchImage(for: photo) { (data: Data?) -> Void in
            guard let imageData = data,
                let _ = UIImage(data: imageData) else {
                print("Image data could not be extracted")
                    return
                }
            DispatchQueue.main.async {
                self.addFlickrPhotoToDatabase(imageData: imageData)
            }
        }
    }

    
    // MARK: - Add FlickrPhoto to Database
    
    func addFlickrPhotoToDatabase(imageData: Data) {
        let newFlickrPhoto = FlickrPhoto(imageData: imageData, context: fetchedResultsController.managedObjectContext)
        print("Created new photo: \(String(describing: newFlickrPhoto))")
    }
    
    // MARK: - Remove FlickrPhoto from Database
    
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects! {
            sharedContext.delete(photo)
        }
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete: [FlickrPhoto] = []
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.object(at: indexPath))
        }
        for photo in photosToDelete {
            sharedContext.delete(photo)
        }
        selectedIndexes = [IndexPath]()
    }

    // MARK: - Import new photos or delete photos

    @IBAction func importNewPhotos(_ sender: Any) {

        if isEditingPhotoAlbum {
            deleteSelectedPhotos()
            isEditingPhotoAlbum = false
        } else {
            deleteAllPhotos()
            fetchImages()
        }
        configureButton()
    }

}

