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
    var weatherInfo = Dictionary<String,String>()
    var weatherCondition_image = UIImageView()

    var cityNameForDetails = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
        tableView.dataSource = self
        tableView.delegate = self
        print("lats and longs from 1st screen:", latitude,longitude)

        print("image", weatherCondition_image)
    }
    
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddLocation" {
            let destination = segue.destination as! AddLocationViewController
            destination.latitude = latitude
            destination.longitude = longitude
            destination.vc.locations = locations
            
            destination.delegate = self
        }
        
        if segue.identifier == "goToDetails" {
            let destination = segue.destination as! DetailsViewController
            destination.locationName = cityNameForDetails
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
        
        let location = CLLocation(latitude: lat, longitude: lon)
        let radiusInMeters: CLLocationDegrees = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }

    func addAnnotaation(location: CLLocation, weatherInfo: Dictionary<String,String> ){

        let locationCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let subTitle = "\(weatherInfo["temp"]!), Feels like \(weatherInfo["feels_like"]!)"

        let annotation = MyAnnotation(coordinate: locationCoordinate,title: weatherInfo["weather_condition"]! , subtitle :  subTitle, glyphText: weatherInfo["temp"]!)
        
        
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
        self.cityNameForDetails = location.title
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(locations[indexPath.item].title)
        self.cityNameForDetails = locations[indexPath.item].title
        setupMap(lat: locations[indexPath.item].lat, lon: locations[indexPath.item].lon)
        tableView.deselectRow(at: indexPath, animated: true)
                
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got the location")
        if let location = locations.last {
             latitude = location.coordinate.latitude
             longitude = location.coordinate.longitude
            print("\(latitude), \(longitude)")
            weatherInfo["name"] = "My Location"
            weatherInfo["temp"] = "3.0"
            weatherInfo["weather_condition"] = "Overcast"
            weatherInfo["feels_like"] = "1.0"
            setupMap(lat: latitude, lon: longitude)
            addAnnotaation(location: location, weatherInfo: weatherInfo)

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
            
            if locations.count == 0 {
                let image = UIImage(systemName: "graduationcap.circle.fill")
                view.leftCalloutAccessoryView = UIImageView(image: image)
            } else {
                view.leftCalloutAccessoryView = UIImageView(image: weatherCondition_image.image)
            }
            let temperature = Double(weatherInfo["temp"]!)
            
            if  temperature! > 35.00 {
                view.markerTintColor = UIColor(red: 153.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
                view.tintColor = UIColor(red: 153.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
            } else if temperature! >=  25 && temperature! < 30 {
                view.markerTintColor = UIColor.systemRed
                view.tintColor = UIColor.systemRed
            } else if temperature! >=  17 && temperature! < 24 {
                view.markerTintColor = UIColor.systemOrange
                view.tintColor = UIColor.systemOrange
            } else if temperature! >  12 && temperature! < 16 {
                view.markerTintColor = UIColor.systemBlue
                view.tintColor = UIColor.systemBlue
            } else if temperature! > 0 && temperature! < 11 {
                view.markerTintColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 153.0/255, alpha: 1.0)
                view.tintColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 153.0/255, alpha: 1.0)
            } else {
                view.markerTintColor = UIColor.systemPurple
                view.tintColor = UIColor.systemPurple
            }
        }
        
        if let myAnnotation = annotation as? MyAnnotation {
            view.glyphText = myAnnotation.glyphText
        }

        return view

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "goToDetails", sender: self)

    }
}

extension ViewController: UpdateLocationsDelegate {
    func weatherInfo(weatherData: Dictionary<String, String>, locationData: Dictionary<String, Double>, image: UIImageView) {
        weatherCondition_image = image
        self.weatherInfo = weatherData
        print("weatherData: ",self.weatherInfo)
        print("updated image", self.weatherCondition_image)

        self.setupMap(lat: locationData["lat"]!, lon: locationData["lon"]!)
        let location = CLLocation(latitude: locationData["lat"]!, longitude: locationData["lon"]!)
        self.addAnnotaation(location: location, weatherInfo: weatherInfo)

    }
    
    func UpdateLocations(locations: locationStruct) {
        self.locations.append(locations)
        print("new locationadded:,",self.locations)
        self.tableView.reloadData()
        print("Locations updated",self.locations)
    }
}


struct locationStruct {
    let title: String
    let temp: String
    let lat: Double
    let lon: Double
}


class MyAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText = glyphText
        super.init()
    }
}
