//
//  SearchFeature.swift
//  Search
//
//  Created by Inumaki on 15.05.24.
//

import Architecture
import Combine
import RelayClient
import RepoClient
@preconcurrency import SharedModels
import SwiftUI

@Reducer
public struct RepoFeature: Reducer {
    @Dependency(\.relayClient) var relayClient
    @Dependency(\.repoClient) var repoClient

    @ObservableState
    public struct State: FeatureState {
        // swiftlint:disable redundant_optional_initialization
        public var installRepoMetadata: RepoMetadata? = nil
        // swiftlint:enable redundant_optional_initialization
        public var repos: [RepoMetadata] = []
        public init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case onAppear
            case install(url: String)
            case fetch(url: String)
            case installWithModules(_ metadata: RepoMetadata, modules: [String])
            case installModule(_ metadata: RepoMetadata, id: String)

            case setMetadata(_ metadata: RepoMetadata)
        }

        @CasePathable
        @dynamicMemberLookup
        public enum DelegateAction: SendableAction {}

        @CasePathable
        @dynamicMemberLookup
        public enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }

    func getRepos() -> [RepoMetadata] {
        let fileManager = FileManager.default

        // Get the path to the user's Documents directory
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not locate the Documents directory.")
            return []
        }

        // Append the "Repos" folder to the path
        let reposDirectory = documentsDirectory.appendingPathComponent("Repos")

        do {
            // Get the list of all items in the "Repos" directory
            let items = try fileManager.contentsOfDirectory(at: reposDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            var repoArray: [RepoMetadata] = []
            for item in items {
                var isDirectory: ObjCBool = false

                // Check if the item is a directory
                if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory), isDirectory.boolValue {
                    // Construct the path to the "metadata.json" file
                    let metadataFilePath = item.appendingPathComponent("metadata.json")

                    if fileManager.fileExists(atPath: metadataFilePath.path) {
                        do {
                            // Read the contents of the "metadata.json" file
                            let jsonData = try Data(contentsOf: metadataFilePath)

                            // Convert the JSON data to a string for printing
                            let repo = try JSONDecoder().decode(RepoMetadata.self, from: jsonData)

                            repoArray.append(repo)
                            print("Loaded Repo \(repo.id)")
                        } catch {
                            print("Failed to read JSON file at path: \(metadataFilePath.path), error: \(error)")
                        }
                    } else {
                        print("No metadata.json file found in directory: \(item.path)")
                    }
                }
            }
            return repoArray
        } catch {
            print("Failed to list contents of directory: \(reposDirectory.path), error: \(error)")
        }

        return []
    }

    public init() { }

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
