//
//  AddLocationViewController.swift
//  Project2
//
//  Created by Ankur Kalson on 2022-12-02.
//
import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var converTo: UIButton!
    @IBOutlet weak var degreeLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let config = UIImage.SymbolConfiguration(paletteColors:
                                                [.systemYellow, .systemTeal])
    
    var latitude: String = ""
    var longitude: String = ""
    
    var tempCelsius: String = ""
    var tempFahr: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displayWeatherImage()
        searchTextField.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        degreeLabel.textColor = UIColor.systemTeal
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        onSearch(textField.text!)
        return true
    }
    
    private func displayWeatherImage() {
        weatherImage.preferredSymbolConfiguration = config
        weatherImage.image = UIImage(systemName: "sun.max.fill")

    }


    @IBAction func converToAction(_ sender: Any) {
        
        if(tempLabel.text == "Temp"){
            let alert = UIAlertController(title: "Warning", message: "Please search a city name or click on current location button to get the temperature", preferredStyle: .alert)
            
            let okAction  = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            if tempLabel.text!.contains("C") {
                tempLabel.text = "\(tempFahr)°F"
                degreeLabel.text = "°C"
            }else{
                tempLabel.text = "\(tempCelsius)°C"
                degreeLabel.text = "°F"

            }
        }
        
       
    }
    
    @IBAction func onSearch(_ sender: Any) {
        loadWeather(search: searchTextField.text)
        searchTextField.text = ""
    }
    
    @IBAction func onLocationTapped(_ sender: Any) {
        locationManager.requestLocation()
        loadWeather(search: "\(latitude), \(longitude)")
    }
    
    private func loadWeather(search: String?){
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
                self.tempCelsius = String(weatherResponse.current.temp_c)
                self.tempFahr = String(weatherResponse.current.temp_f)
                
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    self.tempLabel.text = "\(weatherResponse.current.temp_c)°C"
                    self.conditionLabel.text = weatherResponse.current.condition.text
                    
                    let code = weatherResponse.current.condition.code
                    
                    let config = UIImage.SymbolConfiguration(paletteColors:
                    [.systemTeal, .systemYellow])
                    
                    //change background according to time of day
                    if weatherResponse.current.is_day == 1{
                        self.view.backgroundColor = UIColor.white
                        self.searchTextField.backgroundColor = UIColor.white
                        self.searchTextField.textColor = UIColor.black


                    }else{
                        self.view.backgroundColor = UIColor.black
                        self.locationLabel.textColor = UIColor.systemTeal
                        self.tempLabel.textColor = UIColor.systemTeal
                        self.degreeLabel.textColor = UIColor.systemTeal
                        self.conditionLabel.textColor = UIColor.systemTeal
                        self.searchTextField.backgroundColor = UIColor.black
                        self.searchTextField.textColor = UIColor.white
                        
                        
                    }
                    
                    switch code {
                    case 1000 :
                     
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "sun.max.fill")
                    case 1003 :
                        
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud.sun")
                    
                    case 1006 :
                        
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud")
                        
                    case 1009 :
                        
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud.fill")

                    case 1030 :
                        
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud.drizzle")

                    case 1066 :
                        
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud.snow")
                        
                    case 1114 :
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "wind.snow")
                        
                    case 1117 :
                    
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "wind.snow.circle")
                   
                    case 1183 :
                     
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud.sun.rain")
                        
                    case 1195 :
                     
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
                        
                    case 1213 :
                      
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "snowflake")
                        
                    case 1204 :
                    
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud.sleet")
                        
                    case 1135 :
                    
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "cloud.fog.fill")
                    default:
                        self.weatherImage.preferredSymbolConfiguration = config
                        self.weatherImage.image = UIImage(systemName: "sun.min")
                    }

                }
            }
            
        }
        
        dataTask.resume()
    }
    
    private func getUrl(searchParam: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "e038f8bb336c42b485d220603222211"
        guard let url =  "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(searchParam)"
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
}

struct Location: Decodable {
    let name: String
}

struct Weather : Decodable{
    let temp_c: Float
    let temp_f: Float
    let is_day: Int
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

}

extension AddLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got the location")
        if let location = locations.last {
             latitude = String(location.coordinate.latitude)
             longitude = String(location.coordinate.longitude)
            print("\(latitude), \(longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

