//
//  SettingsView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 30.01.24.
//

import Architecture
import Combine
import ComposableArchitecture
import RelayClient
import SharedModels
import UIKit
import ViewComponents

class MyTapGesture: UITapGestureRecognizer {
    var data: RepoMetadata?
}

public class RepoView: UIViewController, UITextFieldDelegate {
    var store: Store<RepoFeature.State, RepoFeature.Action>

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical             = true
        view.contentInsetAdjustmentBehavior   = .never
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let reposStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let textFieldWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let textField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: "Search for repo...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.fg.withAlphaComponent(0.5)]
        )
        field.font = .systemFont(ofSize: 14)
        field.textColor = ThemeManager.shared.getColor(for: .fg)
        field.tintColor = ThemeManager.shared.getColor(for: .accent)
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    public init(store: Store<RepoFeature.State, RepoFeature.Action>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)

        store.send(.view(.onAppear))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        textField.delegate = self

        textFieldWrapper.addSubview(textField)

        textFieldWrapper.tag = 100

        stack.addArrangedSubview(textFieldWrapper)
        stack.addArrangedSubview(reposStack)

        scrollView.addSubview(stack)

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 72),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),

            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            textFieldWrapper.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            textField.leadingAnchor.constraint(equalTo: textFieldWrapper.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: textFieldWrapper.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: textFieldWrapper.topAnchor, constant: 6),
            textField.bottomAnchor.constraint(equalTo: textFieldWrapper.bottomAnchor, constant: -6)
        ])

        observe { [weak self] in
            guard let self else { return }

            if !store.repos.isEmpty {
                // reset repos list
                reposStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

                for index in 0..<store.repos.count {
                    let repo = store.repos[index]
                    let repoDetail = RepoDetailCard(repo)

                    repoDetail.isUserInteractionEnabled = true
                    let tapGesture = MyTapGesture(target: self, action: #selector(handleTap(_:)))
                    tapGesture.data = repo
                    repoDetail.addGestureRecognizer(tapGesture)
                    reposStack.addArrangedSubview(repoDetail)
                }
            }
        }
    }

    @objc func handleTap(_ sender: MyTapGesture) {
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navController = window.rootViewController as? UINavigationController,
        let repo = sender.data else {
            return
        }

        let vc = RepoDetailView(repo)

        navController.navigationBar.isHidden = true

        navController.pushViewController(vc, animated: true)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // This method is called when the user taps the return key on the keyboard
        textField.resignFirstResponder() // Hide the keyboard
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        // Call at the end
        if let text = textField.text {
            // User input goes here.
            store.send(.view(.install(url: text)))
        }
    }
}
