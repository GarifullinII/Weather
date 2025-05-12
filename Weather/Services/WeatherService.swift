//
//  WeatherService.swift
//  Weather
//
//  Created by Ildar Garifullin on 12.05.2025.
//

import Foundation
import CoreLocation

class WeatherService {
    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let baseURL = "https://api.weatherapi.com/v1"
    
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let currentURL = "\(baseURL)/current.json?key=\(apiKey)&q=\(latitude),\(longitude)"
        let forecastURL = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=7"
        
        let group = DispatchGroup()
        var currentData: Data?
        var forecastData: Data?
        var error: Error?
        
        group.enter()
        fetchData(urlString: currentURL) { result in
            switch result {
            case .success(let data):
                currentData = data
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        group.enter()
        fetchData(urlString: forecastURL) { result in
            switch result {
            case .success(let data):
                forecastData = data
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let currentData = currentData else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current weather data"])))
                return
            }
            
            do {
                var response = try JSONDecoder().decode(WeatherResponse.self, from: currentData)
                
                if let forecastData = forecastData {
                    let forecastResponse = try JSONDecoder().decode(WeatherResponse.self, from: forecastData)
                    response.forecast = forecastResponse.forecast
                }
                
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func fetchData(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
