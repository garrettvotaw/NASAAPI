//
//  EarthViewController.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/22/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit
import CoreLocation

class EarthViewController: UIViewController {

    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var earthImageView: UIImageView!
    let client = NasaApiClient()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let location = location {
            getEarthImagery(for: location)
        }
    }
    
    // This function will get the most recent Earth Image given a CLLocation value
    func getEarthImagery(for location: CLLocation) {
        let long = location.coordinate.longitude
        let lat = location.coordinate.latitude
        client.getEarthImage(lat: lat, long: long, date: nil) { [unowned self] earthImage, error in
            if let earthImage = earthImage {
                self.client.getImageFrom(url: earthImage.url) {image, error in
                    if let image = image {
                        self.earthImageView.image = image
                    }
                }
            } else if let error = error {
                switch error {
                case .jsonParsingFailure: self.presentAlert(title: "Parsing Error", message: "Oops! It looks like something went wrong on the backend!")
                case .responseUnsuccessful: self.presentAlert(title: "Response Unsuccessful", message: "It looks like your network might be down. Please try again.")
                default: self.presentAlert(title: "Something Went Wrong", message: "Oops! It looks like something went wrong on the backend!")
                }
            }
        }
    }
    
    @IBAction func getCurrentLocationPhoto(_ sender: Any) {
        guard let currentLocation = currentLocation else {return}
        getEarthImagery(for: currentLocation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension EarthViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        currentLocation = location
        getEarthImagery(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            searchButton.isEnabled = false
        }
    }
    
    
}
