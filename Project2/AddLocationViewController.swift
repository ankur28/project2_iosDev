//
//  AddLocationViewController.swift
//  Project2
//
//  Created by Ankur Kalson on 2022-12-02.
//
import UIKit
import CoreLocation

protocol UpdateLocationsDelegate {
    func UpdateLocations(locations: locationStruct)
    func weatherInfo(weatherData: Dictionary<String,String>,locationData: Dictionary<String,Double>, image: UIImageView)
}

class AddLocationViewController: UIViewController, UITextFieldDelegate {

    var delegate : UpdateLocationsDelegate?
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var degreeLabel: UILabel!
    
    let config = UIImage.SymbolConfiguration(paletteColors:
                                                [.systemYellow, .systemTeal])
    
    var latitude: Double?
    var longitude: Double?

    var tempCelsius: String = ""
    var tempFahr: String = ""
    
    var weatherData = [String:String]()
    var locationData = [String:Double]()

    let vc:ViewController = ViewController()
    var locations: [locationStruct] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displayWeatherImage()
        searchTextField.delegate = self
        
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

    
    @IBAction func onSave(_ sender: Any) {

        if let delegate = delegate{
            delegate.UpdateLocations(locations: locationStruct(title: weatherData["name"]!, temp: "\(weatherData["temp"]!)C",lat: locationData["lat"]!, lon: locationData["lon"]!))
            delegate.weatherInfo(weatherData: weatherData, locationData: locationData, image: weatherImage)
        }
        dismiss(animated: true)

    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func onSearch(_ sender: Any) {
        loadWeather(search: searchTextField.text)
        searchTextField.text = ""
                
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
                self.tempCelsius = String(weatherResponse.current.temp_c)
                self.tempFahr = String(weatherResponse.current.temp_f)
                
                DispatchQueue.main.async {
                    self.tempLabel.text = "\(weatherResponse.current.temp_c)°C"
                    self.conditionLabel.text = weatherResponse.current.condition.text
                    self.locationLabel.text = weatherResponse.location.name

                    let code = weatherResponse.current.condition.code
                    self.weatherData["temp"] = String((weatherResponse.current.temp_c))
                    self.weatherData["weather_condition"] = weatherResponse.current.condition.text
                    self.weatherData["name"] = weatherResponse.location.name
                    self.weatherData["feels_like"] = String(weatherResponse.current.feelslike_c)
                    self.weatherData["code"] = String(code)
                    self.locationData["lat"] = weatherResponse.location.lat
                    self.locationData["lon"] = weatherResponse.location.lon
                    
                    
                    self.latitude = weatherResponse.location.lat
                    self.longitude = weatherResponse.location.lon

                    
                  print(weatherResponse.forecast.forecastday[0].day.maxtemp_c)
                    self.weatherData["high"] = String(weatherResponse.forecast.forecastday[0].day.maxtemp_c)
                    self.weatherData["low"] = String(weatherResponse.forecast.forecastday[0].day.mintemp_c)
                    
                    print(weatherResponse.forecast.forecastday)
                    let config = UIImage.SymbolConfiguration(paletteColors:
                    [.systemTeal, .systemYellow])
                    
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
                    print("lats and longs from api : ",weatherResponse.location.lat,weatherResponse.location.lon)
                    
                }

            }
            
        }
 
        dataTask.resume()
    }
    
    private func getUrl(searchParam: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "forecast.json"
        let apiKey = "e038f8bb336c42b485d220603222211"
        guard let url =  "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(searchParam)&days=7&aqi=no&alerts=no"
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


