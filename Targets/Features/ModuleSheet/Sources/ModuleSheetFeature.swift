//
//  ModuleSheetFeature.swift
//
//
//  Created by Inumaki on 19.10.23.
//

import Architecture
import ComposableArchitecture
import ModuleClient
import OSLog
import SharedModels
import SwiftUI

@Reducer
public struct ModuleSheetFeature: Feature {
  let logger = Logger(subsystem: "com.inumaki.Chouten", category: "ModuleSheet")

  @ObservableState
  public struct State: FeatureState {
    public var selectedModuleId: String = ""
    public var availableModules: [Module] = []
    public var selectedModule: Module?

    public init() {}
  }

  @Dependency(\.moduleClient) var moduleClient

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
    public enum ViewAction: SendableAction {
      case selectModule(module: Module)
      case onAppear
    }

    @CasePathable
    public enum DelegateAction: SendableAction {}

    @CasePathable
    public enum InternalAction: SendableAction {
      case setCurrentModule(Module?)
    }

    case view(ViewAction)
    case delegate(DelegateAction)
    case `internal`(InternalAction)
  }

  @MainActor
  public struct View: FeatureView {
    public let store: StoreOf<ModuleSheetFeature>

    @SwiftUI.State var offset = CGFloat.zero
    @SwiftUI.State var lastOffset = CGFloat.zero
    @SwiftUI.State var animateScroll = false

    let minimum: CGFloat = 50

    public nonisolated init(store: StoreOf<ModuleSheetFeature>) {
      self.store = store
    }
  }

  public init() {}
}
