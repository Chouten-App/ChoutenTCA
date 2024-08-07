//
//  InfoViewRefactor.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.02.24.
//

import Architecture
import Combine
import ComposableArchitecture
import RelayClient
import SharedModels
import UIKit
import ViewComponents

public class InfoViewRefactor: LoadableViewControllerBase {
    var store: Store<InfoFeature.State, InfoFeature.Action>

    let loadingInfoVC = LoadingInfoVC()
    let errorInfoVC = UIViewController()
    let successInfoVC = SuccessInfoVC(infoData: .freeToUseData)

    let topBar = InfoTopBar(title: InfoData.freeToUseData.titles.primary)

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    public init(url: String) {
        store = .init(
            initialState: .init(),
            reducer: { InfoFeature() }
        )
        super.init(loadingViewController: loadingInfoVC, errorViewController: errorInfoVC, successViewController: successInfoVC)

        store.send(.view(.onAppear(url)))
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(loadingViewController: UIViewController, errorViewController: UIViewController, successViewController: UIViewController, waitingViewController: UIViewController? = nil) {
        fatalError("init(loadingViewController:errorViewController:successViewController:waitingViewController:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // view.addSubview(loadingInfoVC.view)
        // addChild(loadingInfoVC)

//        let activityIndicator = UIActivityIndicatorView(style: .medium)
//        activityIndicator.color ThemeManager.shared.getColor(for: .fg)
//
//        // Center the activity indicator in the view
//        activityIndicator.center = loadingInfoVC.view.center
//
//        loadingInfoVC.view.addSubview(activityIndicator)
//
//        activityIndicator.startAnimating()

        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        observe { [weak self] in
            guard let self else { return }

            if let infoData = self.store.infoData, let success = self.successViewController as? SuccessInfoVC {
                print("updating info")

                success.doneLoading = self.store.doneLoading

                success.infoData = infoData

                success.updateData()

                self.showSuccess()
            }
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 16.0, *) {
            if let windowScene = view.window?.windowScene {
                let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
                windowScene.requestGeometryUpdate(geometryPreferences) { error in
                    print("Error requesting geometry update: \(error.localizedDescription)")
                }
            }
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let topPadding = window?.safeAreaInsets.top ?? 0.0

        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.heightAnchor.constraint(equalToConstant: topPadding + 40),
            topBar.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        ])
    }
}
