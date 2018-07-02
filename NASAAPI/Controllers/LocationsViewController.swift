//
//  LocationsViewController.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/30/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationsViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var locations = [MKMapItem]()
    var locationRequest: MKLocalSearchRequest?
    let manager = CLLocationManager()
    var region: MKCoordinateRegion?
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        manager.delegate = self
        manager.requestLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        let placemark = locations[indexPath.row].placemark
        guard let city = placemark.locality, let state = placemark.administrativeArea, let address = placemark.name, let zip = placemark.postalCode else {print("no");return cell}
        let formattedLocation = "\(address) \(city), \(state) \(zip)"
        cell.textLabel?.text = formattedLocation

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = locations[indexPath.row]
        let location = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
        self.location = location
        let previousViewController = navigationController?.viewControllers[0] as! EarthViewController
        previousViewController.location = location
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! EarthViewController
        nextVC.location = location
        print("BOOOOOM")
    }

}

// MARK: - CLLocationManager Delegate Methods
extension LocationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 30000.0, 30000.0)
        self.region = region
        print("received coordinate")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - Search Bar Delegate Methods
extension LocationsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let region = region else {return}
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = region
        locationRequest = request
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let request = locationRequest else {return}
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                self.locations = response.mapItems
                self.tableView.reloadData()
                print("response succeed")
            }
            if let error = error {
                self.locations = []
                print("Tacos")
                print(error)
            }
        }
    }
}
