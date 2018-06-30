//
//  MarsRoverListController.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/20/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit

class MarsRoverListController: UICollectionViewController {
    
    

    let client = NasaApiClient()
    var photos = [Photo]()
    var selectedImage: UIImage?
    let pendingOperations = PendingOperations()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundView = UIImageView(image: #imageLiteral(resourceName: "SpaceBackground"))
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        getMarsImages(date: yesterday, numberOfPages: 2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getMarsImages(date: Date, numberOfPages pages: Int) {
        
        var page = 1
        while page <= pages {
            client.getMarsPhotos(date: date, page: page) { [unowned self] photos, error in
                if let photos = photos {
                    self.photos.append(contentsOf: photos)
                    self.collectionView?.reloadData()
                } else if let error = error {
                    print(error)
                    if error == APIError.noPhotos {
                        let day = Calendar.current.date(byAdding: .day, value: -1, to: date)!
                        page = pages - 1
                        self.getMarsImages(date: day, numberOfPages: 2)
                    }
                }
            }
            page += 1
        }
        
    }
    
    
    func downloadImageFor(_ photo: Photo, at indexPath: IndexPath) {
        if let _ = pendingOperations.downloadsInProgress[indexPath] {
            return
        }

        let downloader = ImageDownloader(photo: photo)
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    

    // MARK: - Collection view data source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoverCell", for: indexPath) as! RoverCell
        
        if let image = photos[indexPath.row].image {
            cell.roverImageView.image = image
        } else {
            downloadImageFor(photos[indexPath.row], at: indexPath)
        }
        
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = photos[indexPath.row].image
        performSegue(withIdentifier: "ShowDetailMarsRover", sender: nil)
        
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let marsVC = segue.destination as? MarsDetailViewController else { return }
        marsVC.image = selectedImage
    }

}
