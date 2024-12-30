//
//  YourResourceLoaderDelegate.swift
//  Chouten
//
//  Created by Inumaki on 06/11/2024.
//

import UIKit
import AVFoundation

class VideoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let replacedUrl = loadingRequest.request.url?.absoluteString.replacingOccurrences(of: "custom-scheme", with: "https")
        guard let replacedUrl,
              let requestURL = URL(string: replacedUrl) else { return false }
        
        // Load data with URLSession without changing the extension
        let task = URLSession.shared.dataTask(with: requestURL) { data, response, error in
            print("responding with data from \(requestURL.absoluteString)")
            print("response type: \(response?.mimeType ?? "nil")")
            
            if let data = data {
                // Respond with the downloaded data
                loadingRequest.dataRequest?.respond(with: data)
                loadingRequest.finishLoading()
            } else {
                loadingRequest.finishLoading(with: error)
            }
        }
        task.resume()
        
        return true
    }
}
