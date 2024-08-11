//
//  SplashScreenViewController.swift
//  App
//
//  Created by Inumaki on 06.08.24.
//

import Architecture
import SharedModels
import UIKit

public class SplashScreenViewController: UIViewController {
    let imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "Icon"))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Chouten"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your all-in-one multimedia\nApp"
        label.font = .systemFont(ofSize: 16)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let appView: AppViewController

    public init(_ module: Module?) {
        self.appView = AppViewController(module)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAnimation()
    }

    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        imageView.layer.zPosition = 100
        titleLabel.layer.zPosition = 101
        subtitleLabel.layer.zPosition = 102

        titleLabel.alpha = 0.0
        subtitleLabel.alpha = 0.0

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -20),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -8)
        ])
    }

    private func startAnimation() {
        // Add your animation code here
        UIView.animate(withDuration: 0.6, delay: 1.0, animations: {
            self.imageView.transform = CGAffineTransform(translationX: 0, y: -80)
        }) { _ in
            UIView.animate(withDuration: 0.6, delay: 0.2, animations: {
                self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -40)
                self.titleLabel.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.6, delay: 0.2, animations: {
                    self.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: -32)
                    self.subtitleLabel.alpha = 1.0
                }) { _ in
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene
                    let window = windowScene?.windows.first

                    if let window {
                        UIView.transition(with: window, duration: 0.6, options: .transitionCrossDissolve, animations: {
                            window.rootViewController = UINavigationController(rootViewController: self.appView)
                        })
                    }
                }
            }
        }
    }
}
