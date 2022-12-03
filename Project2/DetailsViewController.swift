//
//  DetailsViewController.swift
//  Project2
//
//  Created by Ankur Kalson on 2022-12-02.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var temp_label: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var weatherCondition_label: UILabel!
    
    @IBOutlet weak var highTemp_label: UILabel!
    
    @IBOutlet weak var lowTemp_label: UILabel!
    
    @IBOutlet weak var forecastListView: UITableView!
    
    var locationName: String?
    
    var forecastArr: [ForecastStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeather(search: locationName!)

        forecastListView.dataSource = self

//        locationLabel.text = locationName
//        temp_label.text = "\(curr_temp!)C"
//        weatherCondition_label.text = weather_cond
//        highTemp_label.text = "\(high!)C"
//        lowTemp_label.text = "\(low!)C"
        print(locationName!)
        
        
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
                //    print(weatherResponse.forecast.forecastday)

                    self.locationLabel.text = weatherResponse.location.name
                    self.temp_label.text = String(weatherResponse.current.temp_c)
                    self.weatherCondition_label.text = weatherResponse.current.condition.text
                    self.highTemp_label.text = String(weatherResponse.forecast.forecastday[0].day.maxtemp_c)
                    self.lowTemp_label.text = String(weatherResponse.forecast.forecastday[0].day.mintemp_c)
               
                    for value in weatherResponse.forecast.forecastday {
                        let date = value.date
                        let maxTemp = value.day.maxtemp_c
                        let minTemp = value.day.mintemp_c
                        let condition = value.day.condition.text
                        
                        
                        self.forecastArr.append(ForecastStruct(date: date, maxtemp_c: maxTemp, mintemp_c: minTemp, condition: condition))
                    }
                    
                    print(self.forecastArr)
                    
                }

            }
            
        }
        dataTask.resume()
        
        forecastListView.reloadData()
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

struct ForecastStruct {
    let date: String
    let maxtemp_c: Float
    let mintemp_c: Float
    let condition: String
}


extension DetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastList", for: indexPath)
        
        let forecast = forecastArr[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = forecast.date
      //  content.secondaryText = location.temp
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forecastArr.count
    }
}
