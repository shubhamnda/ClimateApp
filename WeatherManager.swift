//
//  WeatherManager.swift
//  Clima
//
//  Created by Shubham Nanda on 13/07/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURl = "https://api.openweathermap.org/data/2.5/weather?"
    var delegate: WeatherManagerDelegate?
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURl)&q=\(cityName)&appid=d8b6b7a76f97addbb7a811b751a6f63c&units=metric#"
        performRequest(with: urlString)
       
    }
    func fetchWeather(latitude: CLLocationDegrees , longitude: CLLocationDegrees){
        let urlString = "\(weatherURl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String){
        // create URL
        if let url = URL(string: urlString){
            //create url session
            let session = URLSession(configuration: .default)
         
            // give session a task
            let task = session.dataTask(with: url) { data, Result, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather =  self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                    
//                    let dataString = String(data: safeData, encoding: .utf8)
//                    print(dataString)
                }// we have used closure here

            }
            // start task
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
         let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
        return weather
        
          
        }
     catch {
         delegate?.didFailWithError(error: error)
         return nil
     }
    }
    
}
