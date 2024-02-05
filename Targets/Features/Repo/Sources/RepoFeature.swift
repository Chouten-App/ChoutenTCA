//
//  RepoFeature.swift
//
//
//  Created by Inumaki on 14.12.23.
//

import Architecture
import ComposableArchitecture
import SharedModels
import SwiftUI

public struct RepoFeature: Feature {
  public struct State: FeatureState {
    public init() {}
  }

  public enum Action: FeatureAction {
    public enum ViewAction: SendableAction {}
    public enum DelegateAction: SendableAction {}
    public enum InternalAction: SendableAction {}

    case view(ViewAction)
    case delegate(DelegateAction)
    case `internal`(InternalAction)
  }

  @MainActor
  public struct View: FeatureView {
    public let store: StoreOf<RepoFeature>
    @SwiftUI.State var showContextMenu = false
    @SwiftUI.State var hoveredIndex = -1
    @GestureState var press = false
    @SwiftUI.State var selectedTags: [Int] = []

    @Namespace var animation

    let installedModules: [Module] = [
      Module.sample,
      Module.sample2,
      Module.sampleUpdate
    ]

    func getFilteredModules() -> [Module] {
      // filter using tags
      let subtypesSet: Set<String> = Set(installedModules.flatMap(\.subtypes))

      // Convert the Set back to an array to remove duplicates
      let uniqueSubtypesArray: [String] = Array(subtypesSet).sorted(using: .localized)

      let filtered = uniqueSubtypesArray.enumerated().compactMap { index, subtype in
        selectedTags.contains(index) ? subtype : nil
      }

      var filteredModules = installedModules.filter { module in
        // Filter the modules based on whether any subtype matches the filtered tags
        let matchingSubtypes = module.subtypes.filter { subtype in
          filtered.contains(subtype)
        }

        return !matchingSubtypes.isEmpty // Filter out modules with no matching subtypes
      }

      if selectedTags.isEmpty {
        return installedModules
      }

      return filteredModules
    }

    public nonisolated init(store: StoreOf<RepoFeature>) {
      self.store = store
    }
  }

  public init() {}
}
