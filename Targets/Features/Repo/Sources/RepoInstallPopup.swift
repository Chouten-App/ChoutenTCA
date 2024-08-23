//
//  RepoInstallPopup.swift
//  Repo
//
//  Created by Inumaki on 14.06.24.
//

import Architecture
import ComposableArchitecture
import SharedModels
import UIKit
import Combine
import ViewComponents

private var associatedStringHandle: UInt8 = 0

extension UIGestureRecognizer {
    var associatedString: String? {
        get {
            objc_getAssociatedObject(self, &associatedStringHandle) as? String
        }
        set {
            objc_setAssociatedObject(self, &associatedStringHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// swiftlint:disable type_body_length
public class RepoInstallPopup: UIViewController {
    let topbar: UIView = {
        let bar = UIView()

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        let doneText = UILabel()
        doneText.text = "Done"
        doneText.textColor = ThemeManager.shared.getColor(for: .fg)
        doneText.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        doneText.translatesAutoresizingMaskIntoConstraints = false

        let hiddenText = UILabel()
        hiddenText.text = "Done"
        hiddenText.textColor = ThemeManager.shared.getColor(for: .fg)
        hiddenText.alpha = 0.0
        hiddenText.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        hiddenText.translatesAutoresizingMaskIntoConstraints = false

        let settingsText = UILabel()
        settingsText.text = "Install a Repo"
        settingsText.textColor = ThemeManager.shared.getColor(for: .fg)
        settingsText.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        settingsText.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(doneText)
        stack.addArrangedSubview(settingsText)
        stack.addArrangedSubview(hiddenText)

        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(effectView)
        bar.sendSubviewToBack(effectView)
        bar.addSubview(stack)

        effectView.alpha = 0.0

        NSLayoutConstraint.activate([
            bar.heightAnchor.constraint(equalToConstant: 52),
            stack.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -12),
            effectView.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            effectView.topAnchor.constraint(equalTo: bar.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: bar.bottomAnchor)
        ])

        return bar
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
            string: "Repo url...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.fg.withAlphaComponent(0.5)]
        )
        field.font = .systemFont(ofSize: 14)
        field.textColor = ThemeManager.shared.getColor(for: .fg)
        field.tintColor = ThemeManager.shared.getColor(for: .accent)
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    let disclaimerTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.text = "Disclaimer:"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let disclaimerDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.numberOfLines = 0

        // swiftlint:disable line_length
        let text = """
        Chouten does not guarantee the safety of any repo or module that isn’t officially made by the Chouten Team. Anything that has the author name “Chouten-Team” but wasn’t found on our server is not by us.
        Install at your own risk.
        """
        // swiftlint:enable line_length

        // Define the ranges for the bold text
        let boldTextRanges = [
            (text as NSString).range(of: "Chouten Team"),
            (text as NSString).range(of: "“Chouten-Team”"),
            (text as NSString).range(of: "not", options: .backwards) // Last occurrence of "not"
        ]

        // Create the attributed string
        let attributedString = NSMutableAttributedString(string: text)

        // Apply 70% opacity color to the entire text
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.fg.withAlphaComponent(0.7)
        ]
        attributedString.addAttributes(regularAttributes, range: NSRange(location: 0, length: text.count))

        // Apply 100% opacity color and bold font to the specified ranges
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.fg.withAlphaComponent(1.0),
            .font: UIFont.boldSystemFont(ofSize: 10)
        ]
        for range in boldTextRanges {
            attributedString.addAttributes(boldAttributes, range: range)
        }

        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let installAlignsideLabel: UILabel = {
        let label = UILabel()
        label.text = "Install alongside"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let noUrlBox = TitleCard("No repo url.", description: "Please enter a repo url in the textbox at the top to install a repo and its modules.")

    let cancelButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Cancel"
        configuration.attributedTitle = AttributedString("Cancel", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.fg
        ]))

        let button = UIButton(configuration: configuration)
        button.backgroundColor = ThemeManager.shared.getColor(for: .overlay)

        button.layer.cornerRadius = 8
        button.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        button.layer.borderWidth = 0.5

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let installButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Install repo"
        configuration.attributedTitle = AttributedString("Install repo", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.fg
        ]))

        let button = UIButton(configuration: configuration)
        button.backgroundColor = ThemeManager.shared.getColor(for: .accent)

        button.layer.cornerRadius = 8

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let repoPicture: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        imageView.layer.cornerRadius = 12
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let authorLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 16)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let modulesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let installingHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()
    
    let installingVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let installingLabel: UILabel = {
        let label = UILabel()
        label.text = "Installing..."
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let installingStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Preparing..."  // Initial status text
        label.font = .systemFont(ofSize: 12)  // Smaller font size
        label.textColor = ThemeManager.shared.getColor(for: .fg).withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let progressView: CircularProgressView = {
        let view = CircularProgressView()
        view.progressColor = ThemeManager.shared.getColor(for: .accent)
        view.trackColor = UIColor(white: 0.9, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cancellables: Set<AnyCancellable> = []

    var store: Store<RepoFeature.State, RepoFeature.Action>
    var selectedModules: [String] = []

    public init(store: Store<RepoFeature.State, RepoFeature.Action>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        configure()
        setupConstraints()

        observe { [weak self] in
            guard let self else { return }
            
            if store.isInstalling {
                installingHorizontalStack.isHidden = false
                installButton.isHidden = true
            } else {
                installingHorizontalStack.isHidden = true
                installButton.isHidden = false
            }
            
            store.publisher.progress.sink { [weak self] progress in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.progressView.progress = progress
                }
            }
            .store(in: &cancellables)
            
            store.publisher.installingStatus.sink { [weak self] status in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.installingStatusLabel.text = status
                }
            }
            .store(in: &cancellables)

            if let metadata = store.installRepoMetadata {
                if noUrlBox.superview != nil {
                   noUrlBox.removeFromSuperview()
                }
                
                if repoPicture.superview == nil {
                    // add icon, titles, modules ui
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

                    if let imageUrl = documentsDirectory?.appendingPathComponent("Repos").appendingPathComponent(metadata.id).appendingPathComponent("icon.png") {
                        let imageData = try? Data(contentsOf: imageUrl)

                        if let imageData {
                            let image = UIImage(data: imageData)

                            repoPicture.image = image
                        }
                    }

                    self.titleLabel.text = metadata.title
                    self.authorLabel.text = metadata.author

                    // run on main thread
                    DispatchQueue.main.async {
                        self.view.addSubview(self.repoPicture)
                        self.view.addSubview(self.titleLabel)
                        self.view.addSubview(self.authorLabel)

                        self.view.addSubview(self.installAlignsideLabel)

                        self.view.addSubview(self.modulesStack)

                        if let modules = metadata.modules {
                            for module in modules {
                                let card = ModuleSelectionCard(module, id: metadata.id, selected: false)
                                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                                tapGesture.associatedString = card.module.id
                                card.addGestureRecognizer(tapGesture)
                                self.modulesStack.addArrangedSubview(card)
                            }
                        }

                        self.view.addSubview(self.installButton)
                        self.installButton.addTarget(self, action: #selector(self.installRepo), for: .touchUpInside)

                        NSLayoutConstraint.activate([
                            self.repoPicture.widthAnchor.constraint(equalToConstant: 80),
                            self.repoPicture.heightAnchor.constraint(equalToConstant: 80),
                            self.repoPicture.topAnchor.constraint(equalTo: self.disclaimerDescription.bottomAnchor, constant: 20),
                            self.repoPicture.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),

                            self.titleLabel.leadingAnchor.constraint(equalTo: self.repoPicture.trailingAnchor, constant: 12),
                            self.titleLabel.bottomAnchor.constraint(equalTo: self.repoPicture.bottomAnchor, constant: -8),

                            self.authorLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
                            self.authorLabel.bottomAnchor.constraint(equalTo: self.titleLabel.topAnchor, constant: -2),

                            self.installAlignsideLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                            self.installAlignsideLabel.topAnchor.constraint(equalTo: self.repoPicture.bottomAnchor, constant: 12),

                            self.modulesStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                            self.modulesStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                            self.modulesStack.topAnchor.constraint(equalTo: self.installAlignsideLabel.bottomAnchor, constant: 12),

                            self.installButton.bottomAnchor.constraint(equalTo: self.cancelButton.topAnchor, constant: -8),
                            self.installButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                            self.installButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                            self.installButton.heightAnchor.constraint(equalToConstant: 40)
                        ])
                    }
                }
            }
        }
    }

    @objc func installRepo() {
        if let metadata = store.installRepoMetadata {
            store.send(.view(.installWithModules(metadata, modules: selectedModules)))
        }
    }

    private func configure() {
        cancelButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        textField.delegate = self
        textFieldWrapper.addSubview(textField)

        view.addSubview(textFieldWrapper)

        view.addSubview(disclaimerTitle)
        view.addSubview(disclaimerDescription)
        view.addSubview(noUrlBox)
        view.addSubview(cancelButton)

        view.addSubview(topbar)
        
        installingVerticalStack.addArrangedSubview(installingLabel)
        installingVerticalStack.addArrangedSubview(installingStatusLabel)
        
        installingHorizontalStack.addArrangedSubview(installingVerticalStack)
        installingHorizontalStack.addArrangedSubview(progressView)
        
        view.addSubview(installingHorizontalStack)
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let topPadding = window?.safeAreaInsets.top ?? 0.0

        NSLayoutConstraint.activate([
            topbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            textFieldWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textFieldWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textFieldWrapper.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 20),

            textField.leadingAnchor.constraint(equalTo: textFieldWrapper.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: textFieldWrapper.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: textFieldWrapper.topAnchor, constant: 6),
            textField.bottomAnchor.constraint(equalTo: textFieldWrapper.bottomAnchor, constant: -6),

            disclaimerTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            disclaimerTitle.topAnchor.constraint(equalTo: textFieldWrapper.bottomAnchor, constant: 12),

            disclaimerDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            disclaimerDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            disclaimerDescription.topAnchor.constraint(equalTo: disclaimerTitle.bottomAnchor, constant: 2),

            noUrlBox.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 80),
            noUrlBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noUrlBox.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            
            installingHorizontalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            installingHorizontalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            installingHorizontalStack.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
            installingHorizontalStack.heightAnchor.constraint(equalToConstant: 40),

            progressView.trailingAnchor.constraint(equalTo: installingHorizontalStack.trailingAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 24),
            progressView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func updateSelectedModules() {
        modulesStack.arrangedSubviews.forEach { view in
            if let moduleCard = view as? ModuleSelectionCard {
                moduleCard.selected = selectedModules.contains(moduleCard.module.id)
                UIView.animate(withDuration: 0.2) {
                    moduleCard.reload()
                }
            }
        }
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let stringValue = sender.associatedString {
            if selectedModules.contains(stringValue) {
                selectedModules.removeAll(where: { $0 == stringValue })
            } else {
                selectedModules.append(stringValue)
            }
        }

        updateSelectedModules()
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true, completion: nil)
    }
}

extension RepoInstallPopup: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // This method is called when the user taps the return key on the keyboard
        textField.resignFirstResponder() // Hide the keyboard
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        // Call at the end
        if let text = textField.text {
            // User input goes here.
            store.send(.view(.fetch(url: text)))
            // store.send(.view(.install(url: text)))
        }
    }
}

