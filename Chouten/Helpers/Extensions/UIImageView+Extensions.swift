//
//  UIImageView+Extensions.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//

import Nuke
import UIKit

 extension UIImageView {
    func setAsyncImage(url: String) {
        if let imageUrl = URL(string: url) {
            let cookies = UserDefaults.standard.string(forKey: "Cookies-\(imageUrl.getDomain() ?? "")")
            var request = URLRequest(url: imageUrl)
            request.setValue(AppConstants.userAgent, forHTTPHeaderField: "User-Agent")
            request.setValue(cookies, forHTTPHeaderField: "Cookie")
            let imageRequest = ImageRequest(urlRequest: request)

            ImagePipeline.shared.loadImage(with: imageRequest) { result in
                do {
                    let imageResponse = try result.get()
                    self.image = imageResponse.image
                } catch {
                    print("\(error)")
                }
            }
        }
    }
}
