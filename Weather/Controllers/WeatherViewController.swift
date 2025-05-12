//
//  WeatherViewController.swift
//  Weather
//
//  Created by Ildar Garifullin on 12.05.2025.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    private let weatherService = WeatherService()
    private let locationService = LocationService()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let loadingView = LoadingView()
    private let errorView = ErrorView()
    
    private let currentWeatherView = CurrentWeatherView()
    private let hourlyForecastView = HourlyForecastView()
    private let dailyForecastView = DailyForecastView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchWeatherData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        errorView.retryHandler = { [weak self] in
            self?.fetchWeatherData()
        }
        view.addSubview(loadingView)
        view.addSubview(errorView)
        
        currentWeatherView.translatesAutoresizingMaskIntoConstraints = false
        hourlyForecastView.translatesAutoresizingMaskIntoConstraints = false
        dailyForecastView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(currentWeatherView)
        contentView.addSubview(hourlyForecastView)
        contentView.addSubview(dailyForecastView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            currentWeatherView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            currentWeatherView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentWeatherView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            hourlyForecastView.topAnchor.constraint(equalTo: currentWeatherView.bottomAnchor, constant: 20),
            hourlyForecastView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hourlyForecastView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hourlyForecastView.heightAnchor.constraint(equalToConstant: 120),
            
            dailyForecastView.topAnchor.constraint(equalTo: hourlyForecastView.bottomAnchor, constant: 20),
            dailyForecastView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dailyForecastView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dailyForecastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func fetchWeatherData() {
        loadingView.isHidden = false
        errorView.isHidden = true
        scrollView.isHidden = true
        
        locationService.getCurrentLocation { [weak self] coordinate in
            let latitude = coordinate?.latitude ?? 55.7558
            let longitude = coordinate?.longitude ?? 37.6173
            
            self?.weatherService.fetchWeather(latitude: latitude, longitude: longitude) { result in
                DispatchQueue.main.async {
                    self?.loadingView.isHidden = true
                    
                    switch result {
                    case .success(let weatherData):
                        self?.scrollView.isHidden = false
                        self?.updateUI(with: weatherData)
                    case .failure(let error):
                        self?.errorView.isHidden = false
                        print("Error fetching weather: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func updateUI(with weatherData: WeatherResponse) {
        currentWeatherView.configure(with: weatherData)
        
        if let forecast = weatherData.forecast {
            let currentHour = Calendar.current.component(.hour, from: Date())
            let todayHours = forecast.forecastday.first?.hour.filter { hour in
                guard let hourString = hour.time.components(separatedBy: " ").last,
                      let hourValue = Int(hourString.components(separatedBy: ":").first ?? "") else {
                    return false
                }
                return hourValue >= currentHour
            } ?? []
            
            let tomorrowHours = forecast.forecastday.dropFirst().first?.hour ?? []
            hourlyForecastView.configure(with: Array((todayHours + tomorrowHours).prefix(24)))
            
            dailyForecastView.configure(with: forecast.forecastday)
        }
    }
}
