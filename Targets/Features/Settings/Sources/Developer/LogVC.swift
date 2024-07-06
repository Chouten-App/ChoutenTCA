//
//  LogVC.swift
//  Settings
//
//  Created by Inumaki on 05.07.24.
//

import Architecture
import UIKit

class LogDisplay: UIView {

    let log: Log

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let lineLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 10)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 10)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 12)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public init(_ log: Log) {
        self.log = log
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        titleLabel.text = log.title
        lineLabel.text = log.line
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: log.time)
        timeLabel.text = dateString
        descriptionLabel.text = log.description

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(lineLabel)
        addSubview(timeLabel)
        addSubview(descriptionLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),

            lineLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 2),
            lineLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2),

            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

class LogVC: UIViewController {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        for (index, log) in LogManager.shared.getLogs().enumerated() {
            let logDisplay = LogDisplay(log)
            contentView.addArrangedSubview(logDisplay)

            if index < LogManager.shared.getLogs().count - 1 {
                contentView.addArrangedSubview(createSeparator())
            }
        }

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 90),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = ThemeManager.shared.getColor(for: .border)
        separator.alpha = 0.5
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.layer.cornerRadius = 0.5
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        return separator
    }
}

