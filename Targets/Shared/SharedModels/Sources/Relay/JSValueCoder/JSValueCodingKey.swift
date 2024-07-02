//
//  JSValueCodingKey.swift
//
//
//  Created by ErrorErrorError on 11/5/23.
//
//

import Foundation

// MARK: - JSValueCodingKey

public struct JSValueCodingKey: CodingKey {
    public static let `super` = Self(stringValue: "super")

    public let stringValue: String
    public let intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(convertingToSnakeCase other: CodingKey) {
        self.init(stringValue: String(convertingToSnakeCase: other.stringValue))
    }

    public init(convertingFromSnakeCase other: CodingKey) {
        self.init(stringValue: String(convertingFromSnakeCase: other.stringValue))
    }
}

extension String {
    fileprivate init(convertingToSnakeCase string: String) {
        guard !string.isEmpty else {
            self = string
            return
        }

        var snakeCase = ""
        var index = string.startIndex
        let firstIndexLetter = string.firstIndex(where: \.isLetter) ?? string.startIndex
        let lastIndexLetter = string.lastIndex(where: \.isNewline) ?? string.endIndex

        while index < string.endIndex {
            let char = string[index]

            if char.isUppercase || char.isWhitespace, firstIndexLetter < index, index < lastIndexLetter {
                snakeCase.append("_")
            }

            snakeCase.append(char.lowercased())

            index = string.index(after: index)
        }

        self = snakeCase
    }

    /// From snake_case to snakeCase
    ///
    fileprivate init(convertingFromSnakeCase string: String) {
        guard !string.isEmpty else {
            self = string
            return
        }

        var nonSnakeCase = ""
        var index = string.startIndex

        var wasLastUnderscore = false

        while index < string.endIndex {
            let char = string[index]

            if char == "_" {
                if index == string.startIndex || index == string.index(before: string.endIndex) {
                    // Append only beginning or ending underscore
                    nonSnakeCase.append(char)
                } else {
                    wasLastUnderscore = true
                }
            } else {
                if wasLastUnderscore {
                    nonSnakeCase.append(char.uppercased())
                } else {
                    nonSnakeCase.append(char.lowercased())
                }
                wasLastUnderscore = false
            }

            index = string.index(after: index)
        }

        self = nonSnakeCase
    }
}
