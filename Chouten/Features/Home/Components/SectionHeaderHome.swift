//
//  SectionHeader.swift
//  Home
//
//  Created by Inumaki on 13.07.24.
//

import UIKit
import Combine
import ComposableArchitecture

class SectionHeaderHome: UICollectionReusableView {
    static let reuseIdentifier: String = "SectionHeaderHome"
    
    var delegate: SectionHeaderHomeDelegate?
    
    var collectionId: String = ""

    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 20, weight: .bold)
        textField.textColor = ThemeManager.shared.getColor(for: .fg)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let deleteButton = CircleButton(icon: "trash")
    
    var onDelete: (() -> Void)?
    var onEdit: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        addSubview(deleteButton)
        addSubview(textField)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
        
        deleteButton.isHidden = true
        deleteButton.tintColor = UIColor(.red)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        // Configure text field
        textField.isHidden = true // Start with text field hidden
        textField.delegate = self
        
        // Enable user interaction on label
        label.isUserInteractionEnabled = true
        
        // Add double-tap gesture recognizer to the label
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        label.addGestureRecognizer(doubleTapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func deleteTapped() {
        onDelete?()
    }
    
    @objc private func handleDoubleTap() {
        // Show text field and hide label
        label.isHidden = true
        textField.isHidden = false
        textField.text = label.text
        textField.becomeFirstResponder() // Focus on text field
    }

    private func finishEditing() {
        // Hide text field and show label with updated text
        textField.isHidden = true
        label.isHidden = false
        label.text = textField.text
        onEdit?(textField.text ?? "")
        
        // update database
        delegate?.didUpdateCollectionName(of: collectionId, to: textField.text ?? "")
    }
    
    func configure(with title: String, id: String) {
        label.text = title
        collectionId = id
    }
}

// Conform to UITextFieldDelegate
extension SectionHeaderHome: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishEditing() // Finish editing when return is pressed
        return true
    }
}
