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

    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()


    }
    

    private func setupMap(){
        print(latitude, longitude)
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let radiusInMeters: CLLocationDegrees = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(coordinateRegion, animated: true)
        addAnnotaation(location: location)
        
//        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: coordinateRegion)
//        mapView.setCameraBoundary(cameraBoundary, animated: true)
//
//        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
//        mapView.setCameraZoomRange(zoomRange, animated: true)
    }

    private func addAnnotaation(location: CLLocation){
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let annotation = MyAnnotation(coordinate: locationCoordinate,title:  "My location", subtitle : "With a subtitle")
        mapView.addAnnotation(annotation)
    }

}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got the location")
        if let location = locations.last {
             latitude = location.coordinate.latitude
             longitude = location.coordinate.longitude
            print("\(latitude), \(longitude)")
            setupMap()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
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

