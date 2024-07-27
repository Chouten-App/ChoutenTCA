//
//  Book.swift
//  SharedModels
//
//  Created by Inumaki on 20.07.24.
//

import Foundation

public enum Section: Hashable {
    case chapter(Double)
}

public struct ImageModel: Hashable {
    public let url: String
    public let chapter: Double
    public let currentChapter: String
    public let nextChapter: String
    public let isFirstChapter: Bool

    public init(url: String, chapter: Double, currentChapter: String = "", nextChapter: String = "", isFirstChapter: Bool = false) {
        self.url = url
        self.chapter = chapter
        self.currentChapter = currentChapter
        self.nextChapter = nextChapter
        self.isFirstChapter = isFirstChapter
    }
}

public enum ReaderMode {
    case auto
    case webtoon
    case verticalPaged
    case ltr
    case rtl
}
