//
//  File.swift
//  
//
//  Created by Inumaki on 17.10.23.
//

public struct SearchData: Codable, Hashable, Equatable, Sendable {
    public let url: String
    public let img: String
    public let title: String
    public let indicatorText: String?
    public let currentCount: Int?
    public let totalCount: Int?
    
    public init(url: String, img: String, title: String, indicatorText: String?, currentCount: Int?, totalCount: Int?) {
        self.url = url
        self.img = img
        self.title = title
        self.indicatorText = indicatorText
        self.currentCount = currentCount
        self.totalCount = totalCount
    }
    
    public var currentCountString: String {
        if let currentCount {
            return "\(currentCount)"
        } else {
            return "⁓"
        }
    }
    
    public var totalCountString: String {
        if let totalCount {
            return "\(totalCount)"
        } else {
            return "⁓"
        }
    }
}
