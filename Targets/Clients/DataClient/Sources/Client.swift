//
//  Client.swift
//
//
//  Created by Inumaki on 29.10.23.
//

import Combine
import ComposableArchitecture
import Dependencies
import DependenciesMacros
import Foundation
import OSLog
import SharedModels

// MARK: - DataClient

@DependencyClient
public struct DataClient: Sendable {
  public var setInfoData: @Sendable (_ infoData: InfoData?) -> Void
  public var getInfoData: @Sendable () -> InfoData?
  public var observeInfoData: @Sendable () -> AsyncStream<InfoData?> = { .never }
  public var setVideoUrl: @Sendable (_ url: String?, _ index: Int?) -> Void
  public var getVideoUrl: @Sendable () -> String?
  public var getVideoIndex: @Sendable () -> Int?
  public var observeVideoUrl: @Sendable () -> AsyncStream<String?> = { .never }
  public var observeVideoIndex: @Sendable () -> AsyncStream<Int?> = { .never }
}

extension DependencyValues {
  public var dataClient: DataClient {
    get { self[DataClient.self] }
    set { self[DataClient.self] = newValue }
  }
}
