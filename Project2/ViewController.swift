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
    
    @IBOutlet weak var mylocationButton: UIButton!
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
    
    @IBAction func onMyLocation(_ sender: Any) {
        locationManager.requestLocation()
    }
    
    
    @IBAction func onAddLocation(_ sender: Any) {
        performSegue(withIdentifier: "goToAddLocation", sender: self)
    }
    
    func setupMap(lat: Double, lon: Double ){
        mapView.delegate = self
        
        let location = CLLocation(latitude: lat, longitude: lon)
        let radiusInMeters: CLLocationDegrees = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
        addAnnotaation(location: location)
    }

    func addAnnotaation(location: CLLocation){

        let locationCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        var subTitle = ""
        if !weatherInfo.isEmpty{
            subTitle = "\(weatherInfo["temp"]!), Feels like \(weatherInfo["feels_like"]!)"
        }

        let annotation = MyAnnotation(coordinate: locationCoordinate,title: weatherInfo["weather_condition"]! , subtitle :  subTitle, glyphText: weatherInfo["temp"]!)
        
        
        mapView.addAnnotation(annotation)
    }
    
    func loadWeather(search: String?){
        guard let search = search else {
            return
        }
        guard let url = getUrl(searchParam: search) else {
            print("Could't get url")
            return
        }

        let urlSession = URLSession.shared
        
        let dataTask = urlSession.dataTask(with: url) {data, response, error in
            print("Network call completed")
            
            guard error == nil else {
                print("Error Recieved")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data) {
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    self.weatherInfo["name"] = weatherResponse.location.name
                    self.weatherInfo["temp"] = String(weatherResponse.current.temp_c)
                    self.weatherInfo["weather_condition"] = weatherResponse.current.condition.text
                    self.weatherInfo["feels_like"] = String(weatherResponse.current.feelslike_c)
//                    self.locations.append(locationStruct(title: weatherResponse.location.name, temp: String(weatherResponse.current.temp_c), lat: weatherResponse.location.lat, lon: weatherResponse.location.lon))
                    self.cityNameForDetails = weatherResponse.location.name
                    self.setupMap(lat: self.latitude, lon: self.longitude)
                    
                    let code = weatherResponse.current.condition.code
                    switch code {
                    case 1000 :
                        
                        self.weatherCondition_image.image = UIImage(systemName: "sun.max.fill")
                    case 1003 :
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud.sun")
                    
                    case 1006 :
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud")
                        
                    case 1009 :
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud.fill")

                    case 1030 :
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud.drizzle")

                    case 1066 :
                        
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud.snow")
                        
                    case 1114 :
                        self.weatherCondition_image.image  = UIImage(systemName: "wind.snow")
                        
                    case 1117 :
                    
                        self.weatherCondition_image.image  = UIImage(systemName: "wind.snow.circle")
                   
                    case 1183 :
                     
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud.sun.rain")
                        
                    case 1195 :
                     
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud.bolt.rain.fill")
                        
                    case 1213 :
                        self.weatherCondition_image.image  = UIImage(systemName: "snowflake")
                        
                    case 1204 :
                    
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud.sleet")
                        
                    case 1135 :
                    
                        self.weatherCondition_image.image  = UIImage(systemName: "cloud.fog.fill")
                    default:
                        self.weatherCondition_image.image  = UIImage(systemName: "sun.min")
                    }
                    
                    
                }
            }
        }
        dataTask.resume()
    }
    
    private func getUrl(searchParam: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "forecast.json"
        let apiKey = "e038f8bb336c42b485d220603222211"
        guard let url =  "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(searchParam)&days=10&aqi=no&alerts=no"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        print(url)
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather : WeatherResponse?
        do {
             weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error while decoding")
        }

        return weather
    }
    
    struct WeatherResponse: Decodable {
       let location: Location
       let current: Weather
       let forecast: ForecastData
    }

    struct Location: Decodable {
       let name: String
       let lat: Double
       let lon: Double
    }

    struct Weather : Decodable{
       let temp_c: Float
       let temp_f: Float
       let is_day: Int
       let condition: WeatherCondition
       let feelslike_c: Float
    }

    struct WeatherCondition: Decodable {
       let text: String
       let code: Int
    }

    struct ForecastData: Decodable {
       let forecastday: [ForecastDay]
    }

    struct ForecastDay: Decodable {
       let date: String
       let day: Day
    }
    struct Day: Decodable {
       let maxtemp_c: Float
       let mintemp_c: Float
       let condition: WeatherCondition
    }


    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationList", for: indexPath)
        
        let location = locations[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = location.title
        content.secondaryText = "\(location.temp) (H: \(weatherInfo["high"]!), \(weatherInfo["low"]!))"
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
            loadWeather(search: "\(latitude),\(longitude)")

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

