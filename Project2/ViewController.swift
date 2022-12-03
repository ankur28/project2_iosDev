//
//  ViewController.swift
//  Project2
//
//  Created by Ankur Kalson on 2022-11-25.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()

    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var locations: [locationStruct] = []
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
        tableView.dataSource = self
        print("lats and longs from 1st screen:", latitude,longitude)

    }
    
    private func loadLocations(){
        locations.append(locationStruct(title: "DUbai", temp: "3C"))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddLocation" {
            let destination = segue.destination as! AddLocationViewController
            destination.latitude = latitude
            destination.longitude = longitude
            destination.vc.locations = locations
            
            destination.delegate = self
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func onAddLocation(_ sender: Any) {
        performSegue(withIdentifier: "goToAddLocation", sender: self)
    }
    
    func setupMap(lat: Double, lon: Double){
        mapView.delegate = self
        
        print(lat, lon)
        let location = CLLocation(latitude: lat, longitude: lon)
        let radiusInMeters: CLLocationDegrees = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(coordinateRegion, animated: true)
        addAnnotaation(location: location)
        
    }

    func addAnnotaation(location: CLLocation){

        let locationCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        print("location is: ",locationCoordinate)

        let annotation = MyAnnotation(coordinate: locationCoordinate,title:  "My location", subtitle : "With a subtitle")
        mapView.addAnnotation(annotation)
    }

    func getTemperatureOnLoad(){
        
        let searchString = "\(latitude), \(longitude)"
        print("stringsearch", searchString)
        //addLocationViewController.loadWeather(search: searchString)
//        print("hello", addLocationViewController.weatherData)

    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationList", for: indexPath)
        
        let location = locations[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = location.title
        content.secondaryText = location.temp
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got the location")
        if let location = locations.last {
             latitude = location.coordinate.latitude
             longitude = location.coordinate.longitude
            print("\(latitude), \(longitude)")
            setupMap(lat: latitude, lon: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myIdentifier"
        var view: MKMarkerAnnotationView
        
        if let dequeuedview = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView{
            dequeuedview.annotation = annotation
            view = dequeuedview
        } else {
            
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y:10)
            
            let button = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = button
            
            let image = UIImage(systemName: "graduationcap.circle.fill")
            view.leftCalloutAccessoryView = UIImageView(image: image)
            
        }
        return view

    }
}

extension ViewController: UpdateLocationsDelegate {
    func weatherInfo(weatherData: Dictionary<String, String>, locationData: Dictionary<String, Double>) {
        print("weatherData: ",weatherData)
        self.setupMap(lat: locationData["lat"]!, lon: locationData["lon"]!)
    }
    
    func UpdateLocations(locations: locationStruct) {
        self.locations.append(locations)
        print("new locationadded:,",self.locations)
        self.tableView.reloadData()
    }
}


struct locationStruct {
    let title: String
    let temp: String
}


class MyAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}
