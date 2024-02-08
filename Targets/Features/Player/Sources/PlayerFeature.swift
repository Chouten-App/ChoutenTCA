//
//  PlayerFeature.swift
//
//
//  Created by Inumaki on 16.10.23.
//

import Architecture
import AVKit
import ComposableArchitecture
import DataClient
import ModuleClient
import SharedModels
import SwiftUI
import Webview

@Reducer
public struct PlayerFeature: Feature {
  @Dependency(\.dataClient) var dataClient
  @Dependency(\.moduleClient) var moduleClient

  @ObservableState
  public struct State: FeatureState {
    public let url: String
    public let index: Int
    public var infoData: InfoData?
    public var module: Module?

    public var fullscreen: Bool = (UIScreen.main.bounds.width / UIScreen.main.bounds.height) > 1
    public var showUI = true

    public var ambientMode = true

    public var webviewState: WebviewFeature.State

    public var videoLoadable: Loadable<VideoData> = .pending

    public var speed: Float = 1.0
    public var server: String = "Vidstreaming (Sub)"
    public var quality: String = "auto"

    public var servers: [ServerData] = []
    public var item: AVPlayerItem?

    public var qualities: [String: String] = [
      "240p": "https://test-streams.mux.dev/x36xhzz/url_2/193039199_mp4_h264_aac_ld_7.m3u8", // 240p
      "360p": "https://test-streams.mux.dev/x36xhzz/url_4/193039199_mp4_h264_aac_7.m3u8", // 360p
      "480p": "https://test-streams.mux.dev/x36xhzz/url_6/193039199_mp4_h264_aac_hq_7.m3u8", // 480p
      "720p": "https://test-streams.mux.dev/x36xhzz/url_0/193039199_mp4_h264_aac_hd_7.m3u8", // 720p
      "1080p": "https://test-streams.mux.dev/x36xhzz/url_8/193039199_mp4_h264_aac_fhd_7.m3u8", // 1080p
      "Auto": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8" // auto
    ]

    public var showMenu = false

    public init(url: String = "", index: Int = 0) {
      self.url = url
      self.index = index
      self.webviewState = WebviewFeature.State(htmlString: "", javaScript: "")
      self.quality = qualities.filter { (key: String, _: String) in
        key.lowercased() == "auto"
      }.first?.key ?? ""
    }
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Action: FeatureAction {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewAction: SendableAction {
      case setPiP(_ value: Bool)
      case setSpeed(value: Float)
      case setServer(value: String)
      case setQuality(value: String)
      case setShowMenu(_ value: Bool)
      case toggleUI

      case navigateBack

      case setQualityDict(_ dict: [String: String])
      case setFullscreen(_ value: Bool)

      case onAppear
      case resetWebviewChange
      case parseResult(data: String)
      case parseVideoResult(data: String)
      case setServers(data: [ServerData])
      case setVideoData(data: VideoData)
      case setCurrentItem(data: VideoData)
      case setLoadable(_ loadableState: Loadable<VideoData>)
      case setInfoData(data: InfoData)
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
    @Perception.Bindable public var store: StoreOf<PlayerFeature>

    @StateObject var playerVM = PlayerViewModel()

    func captureFrame(of playerItem: AVPlayerItem, at time: CMTime, module: Module, url: String) {
      let imageGenerator = AVAssetImageGenerator(asset: playerItem.asset)

      // Set the requested time for the frame
      imageGenerator.appliesPreferredTrackTransform = true
      imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, _, error in
        if let error {
          print("Error generating image: \(error)")
          return
        }

        // Save the captured frame as an image file
        if let cgImage {
          let image = UIImage(cgImage: cgImage)
          saveImage(image, module: module, url: url)
        }
      }
    }

    func saveImage(_ image: UIImage, module: Module, url: String) {
      // Convert image to data
      if let imageData = image.jpegData(compressionQuality: 0.8) {
        // Get the documents directory or your desired directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let framesDirectory = documentsDirectory
            .appendingPathComponent("Frames", isDirectory: true)

          // Create a directory URL based on module ID inside 'Frames' directory
          let moduleDirectory = framesDirectory
            .appendingPathComponent(module.id, isDirectory: true)

          // Create a directory URL based on 'url' inside module directory
          let urlDirectory = moduleDirectory
            .appendingPathComponent(
              URL(string: url)?
                .absoluteString
                .replacingOccurrences(of: "://", with: "_")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: ".", with: "_") ?? "UNKNOWN",
              isDirectory: true
            )

          do {
            // Check if 'Frames' directory exists, if not, create it
            if !FileManager.default.fileExists(atPath: framesDirectory.path) {
              try FileManager.default.createDirectory(at: framesDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            // Check if module directory exists, if not, create it
            if !FileManager.default.fileExists(atPath: moduleDirectory.path) {
              try FileManager.default.createDirectory(at: moduleDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            // Check if 'url' directory exists inside the module directory, if not, create it
            if !FileManager.default.fileExists(atPath: urlDirectory.path) {
              try FileManager.default.createDirectory(at: urlDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            // At this point, the required directories should exist
            // You can proceed with file operations within the 'urlDirectory'
            let fileURL = urlDirectory.appendingPathComponent("frame.jpg")

            // Save the image data to file
            do {
              try imageData.write(to: fileURL)
              print("Frame saved at: \(fileURL)")
            } catch {
              print("Error saving frame: \(error)")
            }
          } catch {
            // Handle any errors that occur during directory creation
            print("Error creating directories: \(error.localizedDescription)")
          }
        }
      }
    }

    func secondsToMinutesSeconds(_ seconds: Int) -> String {
      let hours = (seconds / 3_600)
      let minutes = (seconds % 3_600) / 60
      let seconds = (seconds % 3_600) % 60

      let hourString = hours > 0 ? "\(hours)" : ""
      let minuteString = (minutes < 10 ? "0" : "") + "\(minutes)"
      let secondsString = (seconds < 10 ? "0" : "") + "\(seconds)"

      return (hours > 0 ? hourString + ":" : "") + minuteString + ":" + secondsString
    }

    @MainActor
    public init(store: StoreOf<PlayerFeature>) {
      self.store = store
    }
  }

  public init() {}
}
