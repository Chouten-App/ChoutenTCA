//
//  ZoomableScrollView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 20.09.23.
//

import SwiftUI

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    @State private var scale: CGFloat = 1.0
    
    var content: () -> Content
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        
        let hostingController = UIHostingController(rootView: content())
        scrollView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.parent = self
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableScrollView
        
        init(_ parent: ZoomableScrollView) {
            self.parent = parent
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            parent.scale = scrollView.zoomScale
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
    }
    
    func zoom(scale: CGFloat) {
        /*
        guard let scrollView = currentScrollView else { return }
        scrollView.setZoomScale(scale, animated: true)
        self.scale = scale
         */
    }
    
    /*
    var currentScrollView: UIScrollView? {
        
        guard let scrollView = UIApplication.shared.windows.first?.rootViewController?.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView else {
            return nil
        }
        return scrollView
    }
     */
    
    func isZoomedIn() -> Bool {
        return scale > 1.0
    }
}

#Preview {
    ZoomableScrollView(content: {
        Text("TEXT")
    })
}
