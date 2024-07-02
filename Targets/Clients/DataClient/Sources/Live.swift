//
//  Live.swift
//
//
//  Created by Inumaki on 29.10.23.
//

import Architecture
import Combine
import ComposableArchitecture
import Dependencies
import Foundation
import OSLog
import SharedModels

extension DataClient: DependencyKey {
  public static let liveValue: Self = {
    let infoData = CurrentValueSubject<InfoData?, Never>(nil)
    let videoUrl = CurrentValueSubject<String?, Never>(nil)
    let index = CurrentValueSubject<Int?, Never>(nil)

    return Self(
      setInfoData: { infoData.value = $0 },
      getInfoData: { infoData.value },
      observeInfoData: { infoData.values.eraseToStream() },
      setVideoUrl: { url, video_index in
        videoUrl.value = url
        index.value = video_index
      },
      getVideoUrl: { videoUrl.value },
      getVideoIndex: { index.value },
      observeVideoUrl: { videoUrl.values.eraseToStream() },
      observeVideoIndex: { index.values.eraseToStream() }
    )
  }()
}
