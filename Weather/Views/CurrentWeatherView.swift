//
//  CurrentWeatherView.swift
//  Weather
//
//  Created by Ildar Garifullin on 12.05.2025.
//

import UIKit

class CurrentWeatherView: UIView {
    private let tempLabel = UILabel()
    private let conditionLabel = UILabel()
    private let feelsLikeLabel = UILabel()
    private let windLabel = UILabel()
    private let humidityLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
        
        tempLabel.font = .systemFont(ofSize: 48, weight: .bold)
        tempLabel.textAlignment = .center
        
        conditionLabel.font = .systemFont(ofSize: 20)
        conditionLabel.textAlignment = .center
        
        
        let detailsStack = UIStackView()
        detailsStack.axis = .vertical
        detailsStack.spacing = 4
        
        feelsLikeLabel.font = .systemFont(ofSize: 16)
        windLabel.font = .systemFont(ofSize: 16)
        humidityLabel.font = .systemFont(ofSize: 16)
        
        [feelsLikeLabel, windLabel, humidityLabel].forEach {
            detailsStack.addArrangedSubview($0)
        }
        
        let mainStack = UIStackView(arrangedSubviews: [tempLabel, conditionLabel, detailsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with weatherData: WeatherResponse) {
        tempLabel.text = "\(Int(weatherData.current.temp_c))°"
        conditionLabel.text = weatherData.current.condition.text
        feelsLikeLabel.text = "Feels like \(Int(weatherData.current.feelslike_c))°"
        windLabel.text = "Wind: \(weatherData.current.wind_kph) km/h"
        humidityLabel.text = "Humidity: \(weatherData.current.humidity)%"
    }
}

