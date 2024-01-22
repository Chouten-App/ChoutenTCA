//
//  SwiftUIView.swift
//  
//
//  Created by Inumaki on 16.10.23.
//

import SwiftUI
import Kingfisher

public struct FillAspectImage: View {
    let url: URL?
    
    @State var finishedLoading: Bool = false
    var completionHandler: ((_ image: UIImage) -> Void)? // Completion handler closure

    public init(url: URL?, completion: ((_ image: UIImage) -> Void)? = nil) {
        self.url = url
        self.completionHandler = completion
    }
    
    public var body: some View {
        GeometryReader { proxy in
            
            KFImage.url(url)
                .onSuccess { image in
                    finishedLoading = true
                    completionHandler?(image.image)
                }
                .onFailure { _ in
                    finishedLoading = true
                }
                .resizable()
                .scaledToFill()
                .transition(.opacity)
                .opacity(finishedLoading ? 1.0 : 0.0)
                .background(Color(white: 0.05))
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    alignment: .center
                )
                .contentShape(Rectangle())
                .clipped()
                .animation(.easeInOut(duration: 0.5), value: finishedLoading)
        }
    }
}

#Preview {
    FillAspectImage(url: URL(string: ""))
}
