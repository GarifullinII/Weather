//
//  WeatherResponse.swift
//  Weather
//
//  Created by Ildar Garifullin on 12.05.2025.
//

import Foundation

struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
    var forecast: Forecast?
}

struct Location: Codable {
    let name: String
    let lat: Double
    let lon: Double
}

struct CurrentWeather: Codable {
    let temp_c: Double
    let condition: WeatherCondition
    let wind_kph: Double
    let humidity: Int
    let feelslike_c: Double
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: Day
    let hour: [Hour]
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let avgtemp_c: Double
    let condition: WeatherCondition
}

struct Hour: Codable {
    let time: String
    let temp_c: Double
    let condition: WeatherCondition
}
