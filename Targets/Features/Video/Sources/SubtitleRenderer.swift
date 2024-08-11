//
//  SubtitleRenderer.swift
//  Video
//
//  Created by Inumaki on 07.07.24.
//

import UIKit
import AVKit

struct Subtitle: Hashable {
    let start: Double
    let end: Double
    var text: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(end)
        hasher.combine(text)
    }
}

class SubtitleRenderer: UIView {

    var offset: Double = 0.0
    var subtitles: [Subtitle] = []
    var currentSubtitles: Set<Subtitle> = []

    let fontName = "TrebuchetMS"
    var fontSize = 16.0
    var isPiP = false

    var bottomConstraint: NSLayoutConstraint?

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(url: String) {
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadSubtitles(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                print("Error loading subtitles: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let vttString = String(data: data, encoding: .utf8) {
                self.parseSubtitles(vttString)
            }
        }
        task.resume()
    }

    private func parseSubtitles(_ vttString: String) {
        let lines = vttString.replacingOccurrences(of: "WEBVTT", with: "").components(separatedBy: .newlines)
        var currentSubtitle = Subtitle(start: 0.0, end: 0.0, text: "")

        for (index, line) in lines.enumerated() {
            if line.contains("-->") {
                let times = line.components(separatedBy: " --> ")
                let startTime = parseTimecode(times[0])
                let endTime = parseTimecode(times[1])
                currentSubtitle = Subtitle(start: startTime, end: endTime, text: "")
            } else if !line.isEmpty {
                currentSubtitle.text.append(contentsOf: line + "\n")
            } else {
                // Trim the trailing newline character and append the subtitle
                currentSubtitle.text = currentSubtitle.text.trimmingCharacters(in: .newlines)
                subtitles.append(Subtitle(start: currentSubtitle.start, end: currentSubtitle.end, text: currentSubtitle.text))
                currentSubtitle = Subtitle(start: 0.0, end: 0.0, text: "")
            }

            // Handle the last subtitle in case the file doesn't end with a blank line
            if index == lines.count - 1 && !currentSubtitle.text.isEmpty {
                currentSubtitle.text = currentSubtitle.text.trimmingCharacters(in: .newlines)
                subtitles.append(Subtitle(start: currentSubtitle.start, end: currentSubtitle.end, text: currentSubtitle.text))
            }
        }
    }


    private func parseTimecode(_ timecode: String) -> Double {
        let components = timecode.components(separatedBy: ":")

        switch components.count {
        case 2:
            let minutes = Int(components[0]) ?? 0
            let secondsAndMilliseconds = components[1].components(separatedBy: ".")
            let seconds = Int(secondsAndMilliseconds[0]) ?? 0
            let milliseconds = Int(secondsAndMilliseconds[1]) ?? 0

            let totalSeconds = Double(minutes * 60 + seconds) + Double(milliseconds) / 1000.0
            return totalSeconds
        case 3:
            let hours = Int(components[0]) ?? 0
            let minutes = Int(components[1]) ?? 0
            let secondsAndMilliseconds = components[2].components(separatedBy: ".")
            let seconds = Int(secondsAndMilliseconds[0]) ?? 0
            let milliseconds = Int(secondsAndMilliseconds[1]) ?? 0

            let totalSeconds = Double(hours * 3600 + minutes * 60 + seconds) + Double(milliseconds) / 1000.0
            return totalSeconds
        default:
            return .zero
        }
    }

    func updateSubtitles(for time: CMTime) {
        var newSubtitles: Set<Subtitle> = []

        for subtitle in subtitles {
            if time.seconds >= subtitle.start + offset && time.seconds <= subtitle.end + offset {
                print("Subtitle text: \(subtitle.text)\nSubtitle Start: \(subtitle.start)\nTime: \(time.seconds)")
                newSubtitles.insert(subtitle)
            }
        }

        if newSubtitles != currentSubtitles {
            currentSubtitles = newSubtitles
            updateSubtitleLabels()
        }
    }

    func updateLabelSizes() {
        DispatchQueue.main.async {
            // Remove labels that are no longer needed
            self.stack.arrangedSubviews.forEach { subview in
                if let label = subview as? UILabel {
                    label.removeFromSuperview()
                }
            }

            // Add new labels for current subtitles
            for subtitle in self.currentSubtitles {
                let label = self.createSubtitleLabel(with: subtitle.text)
                if let label {
                    self.stack.addArrangedSubview(label)
                }
            }
        }
    }

    private func updateSubtitleLabels() {
        DispatchQueue.main.async {
            // Remove labels that are no longer needed
            self.stack.arrangedSubviews.forEach { subview in
                if let label = subview as? UILabel, !self.currentSubtitles.contains(where: { $0.text == label.text }) {
                    label.removeFromSuperview()
                }
            }

            // Add new labels for current subtitles
            for subtitle in self.currentSubtitles 
                where !self.stack.arrangedSubviews.contains(where: { ($0 as? UILabel)?.text == subtitle.text }) {
                let label = self.createSubtitleLabel(with: subtitle.text)
                if let label {
                    self.stack.addArrangedSubview(label)
                }
            }
        }
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(stack)
    }

    private func setupConstraints() {
        bottomConstraint = stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)

        NSLayoutConstraint.activate([
            // swiftlint:disable force_unwrapping
            bottomConstraint!,
            // swiftlint:enable force_unwrapping
            stack.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    func updateBottomPadding(multiplier: Double) {
        bottomConstraint?.constant = -(20 * multiplier)
        stack.spacing = 6 * multiplier
        layoutIfNeeded()
    }

    private func createSubtitleLabel(with text: String) -> UILabel? {
        guard let data = text.data(using: .utf16) else {
            return nil
        }

        // Define the default font and other attributes
        let defaultFont = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let boldFont = UIFont(name: "\(fontName)-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
        let italicFont = UIFont(name: "\(fontName)-Italic", size: fontSize) ?? UIFont.italicSystemFont(ofSize: fontSize)
        let textColor = UIColor.white

        do {
            let attributedText = try NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf16.rawValue
                ],
                documentAttributes: nil
            )

            // Apply default font and text color to the entire attributed text
            attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attributes, range, _ in
                var newAttributes = attributes
                if let currentFont = newAttributes[.font] as? UIFont {
                    // Preserve bold and italic styles if present
                    if currentFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
                        newAttributes[.font] = boldFont
                    } else if currentFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                        newAttributes[.font] = italicFont
                    } else {
                        newAttributes[.font] = defaultFont
                    }
                } else {
                    newAttributes[.font] = defaultFont
                }
                newAttributes[.foregroundColor] = textColor
                attributedText.setAttributes(newAttributes, range: range)
            }

            // Apply shadow to the entire attributed text
            let shadow = NSShadow()
            shadow.shadowOffset = CGSize(width: 2, height: 2)
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.7)
            shadow.shadowBlurRadius = 1
            attributedText.addAttributes([.shadow: shadow], range: NSRange(location: 0, length: attributedText.length))

            // Create UILabel and set attributed text
            let label = UILabel()
            label.attributedText = attributedText
            label.textColor = textColor
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false

            return label

        } catch {
            print("Error creating attributed string from HTML: \(error)")
            return nil
        }
    }

}
