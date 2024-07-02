//
//  String+Extensions.swift
//
//
//  Created by Inumaki on 17.10.23.
//

import UIKit

extension String {
    public func heightWithConstrainedWidth(width: CGFloat, font: UIFont, maxLines: Int) -> Double {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        var options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        // Add ellipsis mode if maxLines is specified
        if maxLines > 0 {
            options.insert(.truncatesLastVisibleLine)
        }

        let boundingBox = self.boundingRect(with: constraintRect, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)

        // Calculate height based on maxLines
        if maxLines > 0 {
            let lineHeight = font.lineHeight
            let totalHeight = lineHeight * CGFloat(min(maxLines, Int(boundingBox.height / lineHeight)))
            return totalHeight
        } else {
            return boundingBox.height
        }
    }
}

extension String {
  public func versionCompare(_ otherVersion: String) -> ComparisonResult {
    let versionDelimiter = "."

    var versionComponents = components(separatedBy: versionDelimiter) // <1>
    var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

    let zeroDiff = versionComponents.count - otherVersionComponents.count // <2>

    if zeroDiff == 0 { // <3>
      // Same format, compare normally
      return compare(otherVersion, options: .numeric)
    } else {
      let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
      if zeroDiff > 0 {
        otherVersionComponents.append(contentsOf: zeros) // <5>
      } else {
        versionComponents.append(contentsOf: zeros)
      }
      return versionComponents.joined(separator: versionDelimiter)
        .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
    }
  }
}

// MARK: - String + LocalizedError

extension String: LocalizedError {
  public var errorDescription: String? { self }
}
