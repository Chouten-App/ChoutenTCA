//
//  HostingController.swift
//  ChoutenApp
//
//  Created by Inumaki on 17.10.23.
//

import Architecture
import Foundation
import SwiftUI

class HostingController<Content: View>: UIHostingController<Content> {
  override var prefersHomeIndicatorAutoHidden: Bool { _prefersHomeIndicatorAutoHidden }

  fileprivate var _prefersHomeIndicatorAutoHidden = false {
    didSet {
      setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask { _supportedInterfaceOrientations }

  fileprivate var _supportedInterfaceOrientations = UIInterfaceOrientationMask.all {
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

  init<Inner: View>(wrappedView: Inner) where Content == HostingBox<Inner> {
    let boxed = Boxed<Inner>()
    super.init(rootView: .init(content: wrappedView, boxed: boxed))
    boxed.delegate = self
  }

  @objc dynamic required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

private class Boxed<Inner: View> {
  weak var delegate: HostingController<HostingBox<Inner>>?
}

struct HostingBox<Inner: View>: View {
  let content: Inner
  fileprivate let boxed: Boxed<Inner>

  var body: some View {
    content
      .onPreferenceChange(HomeIndicatorAutoHiddenPreferenceKey.self) { value in
        boxed.delegate?._prefersHomeIndicatorAutoHidden = value
      }
      .onPreferenceChange(SupportedOrientationPreferenceKey.self) { value in
        boxed.delegate?._supportedInterfaceOrientations = value
      }
  }
}
