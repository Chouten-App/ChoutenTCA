//
//  SearchFeature+Reducer.swift
//  Search
//
//  Created by Inumaki on 15.05.24.
//

import Architecture
import Combine
import ComposableArchitecture
import SharedModels
import SwiftUI

extension RepoFeature {
  @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case .onAppear:
            let repos = getRepos()

            state.repos = repos
            return .none
        case .install(let url):
            guard let checkedUrl = URL(string: url) else {
                return .send(.view(.onAppear))
            }

            return .merge(
                .run { _ in
                    do {
                        try await repoClient.installRepo(checkedUrl)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            )
        case .fetch(let url):
            guard let checkedUrl = URL(string: url) else {
                return .send(.view(.onAppear))
            }

            return .merge(
                .run { send in
                    do {
                        let repoMetadata = try await repoClient.fetchRepoDetails(checkedUrl)
                        if let repoMetadata {
                            await send(.view(.setMetadata(repoMetadata)))
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            )
        case let .installWithModules(metadata, modules):
            do {
                // install metadata
                try repoClient.installRepoMetadata(metadata)

                // loop through modules and install them
                if let metadataModules = metadata.modules {
                    for module in metadataModules where modules.contains(where: { $0 == module.id }) {
                        Task {
                            try await repoClient.installModule(metadata, module.id)
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            return .none
        case let .installModule(metadata, id):
            return .run { _ in
                do {
                    // install metadata
                    try await repoClient.installModule(metadata, id)
                } catch {
                    print(error.localizedDescription)
                }
            }
        case .setMetadata(let metadata):
            state.installRepoMetadata = metadata
            return .none
        }
      }
    }
  }
}
