//
//  HostingController.swift
//  ChoutenApp
//
//  Created by Inumaki on 17.10.23.
//

import Foundation
import SwiftUI
import Architecture

class HostingController: UIHostingController<AnyView> {
    override var prefersHomeIndicatorAutoHidden: Bool { _prefersHomeIndicatorAutoHidden }

    var _prefersHomeIndicatorAutoHidden = false {
       didSet {
            setNeedsUpdateOfHomeIndicatorAutoHidden()
       }
   }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { _supportedInterfaceOrientations }

    private var _supportedInterfaceOrientations = UIInterfaceOrientationMask.all {
        didSet {
            if #available(iOS 16, *) {
                #if targetEnvironment(macCatalyst)
                #else
                setNeedsUpdateOfSupportedInterfaceOrientations()
                #endif
            } else {
                UIView.performWithoutAnimation {
                    if _supportedInterfaceOrientations.contains(.portrait) {
                        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
                    } else if _supportedInterfaceOrientations.contains(.landscape) {
                        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                    }
                    UIViewController.attemptRotationToDeviceOrientation()
                }
            }
        }
    }

    override var shouldAutorotate: Bool { true }

    init<V: View>(wrappedView: V) {
        let box = HostingBox()

        super.init(
            rootView:
                AnyView(
                    wrappedView
                        .onPreferenceChange(HomeIndicatorAutoHiddenPreferenceKey.self) { value in
                            box.delegate?._prefersHomeIndicatorAutoHidden = value
                        }
                        .onPreferenceChange(SupportedOrientationPreferenceKey.self) { value in
                            box.delegate?._supportedInterfaceOrientations = value
                        }
                )
        )

        box.delegate = self
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private class HostingBox {
    weak var delegate: HostingController?

}
