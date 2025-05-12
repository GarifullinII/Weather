//
//  DailyForecastView.swift
//  Weather
//
//  Created by Ildar Garifullin on 12.05.2025.
//

import UIKit

class DailyForecastView: UIView {
    private let tableView = UITableView()
    private var dailyData: [ForecastDay] = []
    private let daysToShow = 7
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DailyForecastCell.self, forCellReuseIdentifier: "DailyForecastCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            heightAnchor.constraint(equalToConstant: CGFloat(daysToShow) * 60 + 24)
        ])
    }
    
    func configure(with days: [ForecastDay]) {
        dailyData = Array(days.prefix(daysToShow))
        tableView.reloadData()
        
        print("Показываем дней: \(dailyData.count)")
    }
}

extension DailyForecastView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyForecastCell", for: indexPath) as! DailyForecastCell
        cell.configure(with: dailyData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

class DailyForecastCell: UITableViewCell {
    private let dayLabel = UILabel()
    private let conditionImageView = UIImageView()
    private let maxTempLabel = UILabel()
    private let minTempLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        maxTempLabel.font = .systemFont(ofSize: 16, weight: .medium)
        minTempLabel.font = .systemFont(ofSize: 16)
        minTempLabel.textColor = .secondaryLabel
        
        conditionImageView.contentMode = .scaleAspectFit
        conditionImageView.tintColor = .systemBlue
        
        let tempStack = UIStackView(arrangedSubviews: [maxTempLabel, minTempLabel])
        tempStack.spacing = 8
        
        let stackView = UIStackView(arrangedSubviews: [dayLabel, conditionImageView, tempStack])
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            conditionImageView.widthAnchor.constraint(equalToConstant: 30),
            conditionImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with day: ForecastDay) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: day.date) {
            dateFormatter.dateFormat = "EEEE"
            dayLabel.text = dateFormatter.string(from: date)
        } else {
            dayLabel.text = day.date
        }
        
        maxTempLabel.text = "\(Int(day.day.maxtemp_c))°"
        minTempLabel.text = "\(Int(day.day.mintemp_c))°"
        
        if let iconURL = URL(string: "https:\(day.day.condition.icon)") {
            URLSession.shared.dataTask(with: iconURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.conditionImageView.image = image.withRenderingMode(.alwaysTemplate)
                    }
                }
            }.resume()
        }
    }
}
