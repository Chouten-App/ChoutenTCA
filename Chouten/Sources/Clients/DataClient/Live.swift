//
//  File.swift
//  
//
//  Created by Inumaki on 29.10.23.
//

import Foundation
import OSLog
import Dependencies
import Architecture
import ComposableArchitecture
import Combine

extension DataClient: DependencyKey {
    public static let liveValue: Self = {
        return Self(
            setInfoData: { data in
                infoData.value = data
            },
            getInfoData: {
                return infoData.value
            },
            observeInfoData: {
                infoData.values.eraseToStream()
            },
            setVideoUrl: { url in
                videoUrl.value = url
            },
            getVideoUrl: {
                return videoUrl.value
            },
            observeVideoUrl: {
                videoUrl.values.eraseToStream()
            }
        )
    }()
}
