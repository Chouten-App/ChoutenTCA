//
//  ReaderDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 16.09.23.
//

import Foundation
import ComposableArchitecture

struct ChapterImages: Codable, Equatable {
    let images: [ImageData]
}

struct ImageData: Codable, Equatable, Identifiable {
    let id: String
    let image: String
}

struct ReaderDomain: ReducerProtocol {
    struct State: Equatable {
        var chapterImages: ChapterImages? = nil
        
        var htmlString: String = ""
        var jsString: String = ""
        
        var webviewState = WebviewDomain.State()
    }
    
    enum Action: Equatable {
        case webview(WebviewDomain.Action)
        
        case onAppear
        case parseResult(result: String)
        case setChapterImages(images: ChapterImages)
    }
    
    @Dependency(\.globalData) var globalData
    @Dependency(\.moduleManager) var moduleManager
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.webviewState, action: /Action.webview) {
            WebviewDomain()
        }
        
        Reduce { state, action in
            switch action {
            case .webview:
                return .none
            case .onAppear:
                state.htmlString = ""
                let module = globalData.getModule()
                
                if module != nil {
                    // get search js file data
                    do {
                        state.jsString = try moduleManager.getJsForType("media", 0) ?? ""
                    } catch let error {
                        print(error)
                        let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                        NotificationCenter.default
                            .post(name: NSNotification.Name("floaty"),
                                  object: nil, userInfo: data)
                    }
                    
                    state.htmlString = """
                                <!DOCTYPE html>
                                <html lang="en">
                                <head>
                                    <meta charset="UTF-8">
                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                    <title>Document</title>
                                </head>
                                <body>
                                    
                                </body>
                                </html>
                                """
                    
                    return .merge(
                        .send(.webview(.setRequestType(type: "media"))),
                        .send(.webview(.setHtmlString(newString: state.htmlString))),
                        .send(.webview(.setJsString(newString: state.jsString)))
                    )
                }
                return .none
            case .parseResult(let result):
                if let jsonData = result.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let images = try decoder.decode(ChapterImages.self, from: jsonData)
                        
                        return .send(.setChapterImages(images: images))
                    } catch {
                        print("Error decoding JSON ODSFG:", error)
                    }
                } else {
                    print("Invalid JSON string")
                }
                return .none
            case .setChapterImages(let images):
                state.chapterImages = images
                return .none
            }
        }
    }
}
