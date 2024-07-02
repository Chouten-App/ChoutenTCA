//
//  LoadableViewControllerBase.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.02.24.
//

import UIKit

open class LoadableViewControllerBase: UIViewController {

    public let loadingViewController: UIViewController
    public let errorViewController: UIViewController
    public var successViewController: UIViewController
    private let waitingViewController: UIViewController?

    public required init(
        loadingViewController: UIViewController,
        errorViewController: UIViewController,
        successViewController: UIViewController,
        waitingViewController: UIViewController? = nil
    ) {
        self.loadingViewController = loadingViewController
        self.errorViewController = errorViewController
        self.successViewController = successViewController
        self.waitingViewController = waitingViewController

        super.init(nibName: nil, bundle: nil)

        // Add child view controllers
        addChild(loadingViewController)
        addChild(errorViewController)
        addChild(successViewController)
        if let waitingViewController {
            addChild(waitingViewController)
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Show loading view by default, unless waiting view exists
        loadingViewController.view.alpha = waitingViewController != nil ? 0.0 : 1.0
        errorViewController.view.alpha = 0.0
        successViewController.view.alpha = 0.0

        // Add child views
        view.addSubview(loadingViewController.view)
        view.addSubview(errorViewController.view)
        view.addSubview(successViewController.view)
        if let waitingViewController {
            view.addSubview(waitingViewController.view)
        }

        // Layout child views
        layoutChildViews()
    }

    private func layoutChildViews() {
        NSLayoutConstraint.activate([
            loadingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            errorViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            successViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            successViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            successViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let waitingViewController {
            NSLayoutConstraint.activate([
                waitingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                waitingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                waitingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
                waitingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }

    public func showSuccess() {
        // Set initial alpha values for loading and error views
        // loadingViewController.view.alpha = 0.0
        // errorViewController.view.alpha = 0.0

        // Fade in the success view
        UIView.animate(withDuration: 0.5) {
            self.loadingViewController.view.alpha = 0.0
            self.successViewController.view.alpha = 1.0
        }

        // Activate constraints for all view controllers
        NSLayoutConstraint.activate([
            loadingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            errorViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            successViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            successViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            successViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Layout child views
        layoutChildViews()
    }

    deinit {
        // Remove child view controllers
        loadingViewController.removeFromParent()
        errorViewController.removeFromParent()
        successViewController.removeFromParent()
        if let waitingViewController {
            waitingViewController.removeFromParent()
        }
    }
}
