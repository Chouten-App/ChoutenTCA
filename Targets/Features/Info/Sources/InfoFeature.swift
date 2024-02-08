//
//  InfoFeature.swift
//
//
//  Created by Inumaki on 16.10.23.
//

import Architecture
import ComposableArchitecture
import DataClient
import ModuleClient
import SharedModels
import SwiftUI
import Webview

@Reducer
public struct InfoFeature: Feature {
  @Dependency(\.moduleClient) var moduleClient
  @Dependency(\.dataClient) var dataClient

  @ObservableState
  public struct State: FeatureState {
    public let url: String
    public var webviewState: WebviewFeature.State
    public var state: LoadingStatus = .notStarted
    public var colorTheme = ColorTheme(
      averageColor: .black,
      contrastingTone: .white,
      accentColor: .indigo,
      accentText: .white,
      dark: true
    )
    public var dynamicInfo = true
    public var infoData: InfoData = .sample
    public var infoLoadable: Loadable<InfoData> = .pending
    public var currentPage: Int = 1

    public init(url: String) {
      self.url = url
      self.webviewState = WebviewFeature.State(htmlString: "", javaScript: "")
    }
  }

  public enum LoadingStatus: Sendable {
    case notStarted
    case loading
    case success
    case error
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Action: FeatureAction {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewAction: SendableAction {
      case setColorTheme(_ theme: ColorTheme)

      case onAppear
      case navigateBack
      case info
      case parseResult(data: String)
      case parseMediaResult(data: String)
      case setInfoData(data: InfoData)
      case setMediaList(data: [MediaList])

      case episodeTap(item: MediaItem, index: Int)
    }

    @CasePathable
    @dynamicMemberLookup
    public enum DelegateAction: SendableAction {}

    @CasePathable
    @dynamicMemberLookup
    public enum InternalAction: SendableAction {
      case webview(WebviewFeature.Action)
    }

    case view(ViewAction)
    case delegate(DelegateAction)
    case `internal`(InternalAction)
  }

  @MainActor
  public struct View: FeatureView {
    public let store: StoreOf<InfoFeature>
    @Binding var isVisible: Bool
    @Binding var dragState: CGSize

    let mediaPerPage = 50

    public init(store: StoreOf<InfoFeature>, isVisible: Binding<Bool>, dragState: Binding<CGSize>) {
      self.store = store
      self._isVisible = isVisible
      self._dragState = dragState
    }

    public init(store: StoreOf<InfoFeature>) {
      self.store = store
      self._dragState = .constant(.zero)
      self._isVisible = .constant(true)
    }
  }

  public init() {}
}
