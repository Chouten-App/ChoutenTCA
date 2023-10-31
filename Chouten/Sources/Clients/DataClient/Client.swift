//
//  File.swift
//  
//
//  Created by Inumaki on 29.10.23.
//

import Dependencies
import Foundation
import OSLog
import ComposableArchitecture
import Combine
import SharedModels

public struct DataClient: Sendable {
    public static var infoData: CurrentValueSubject<InfoData?, Never> = .init(nil)
    public static var videoUrl: CurrentValueSubject<String?, Never> = .init(nil)
    
    public var setInfoData: @Sendable (_ infoData: InfoData?) -> Void
    public var getInfoData: @Sendable () -> InfoData?
    public var observeInfoData: @Sendable () -> AsyncStream<InfoData?>
    public var setVideoUrl: @Sendable (_ url: String?) -> Void
    public var getVideoUrl: @Sendable () -> String?
    public var observeVideoUrl: @Sendable () -> AsyncStream<String?>
}

extension DataClient: TestDependencyKey {
    public static let testValue = Self(
        setInfoData: unimplemented(),
        getInfoData: unimplemented(),
        observeInfoData: unimplemented(),
        setVideoUrl: unimplemented(),
        getVideoUrl: unimplemented(),
        observeVideoUrl: unimplemented()
    )
}

public extension DependencyValues {
    var dataClient: DataClient {
        get { self[DataClient.self] }
        set { self[DataClient.self] = newValue }
    }
}
