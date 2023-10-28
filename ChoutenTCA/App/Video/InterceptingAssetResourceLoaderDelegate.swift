//
//  InterceptingAssetResourceLoaderDelegate.swift
//  ChoutenTCA
//
//  Created by Inumaki on 04.10.23.
//

import AVKit
import OrderedCollections

class InterceptingAssetResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private class SubtitleBundle {
        internal init(subtitleDTO: InterceptingAssetResourceLoaderDelegate.SubtitleDTO, playlist: String? = nil) {
            self.subtitleDTO = subtitleDTO
            self.playlist = playlist
        }
        
        let subtitleDTO: SubtitleDTO
        var playlist: String?
    }
    
    private struct SubtitleDTO {
        let language: String
        let title: String
        let url: String
    }
    
    static let videoUrlPrefix = "INTERCEPTEDVIDEO"
    static let subtitleUrlPrefix = "INTERCEPTEDSUBTITLE"
    static let subtitleUrlSuffix = "m3u8"
    static let hlsSubtitleGroupID = "SUBTITLES"
    private let session: URLSession
    private let subtitleBundles: [SubtitleBundle]
    
    init(_ subtitles: [Subtitle]) {
        self.session = URLSession(configuration: .default)
        self.subtitleBundles = subtitles.map({
            SubtitleBundle(subtitleDTO: SubtitleDTO(language: $0.language, title: $0.language, url: $0.url))
        })
    }
    
    deinit {
        print("unloaded")
    }
    
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        let task = URLSession.shared.dataTask(with: .init(url: URL(string: self.subtitleBundles[0].subtitleDTO.url)!)) { data, _, error in
            guard error == nil else {
                return loadingRequest.finishLoading(with: error)
            }
            
            guard let vttString = String(data: data ?? .init(), encoding: .utf8) else {
                return loadingRequest.finishLoading(with: nil)
            }
            
            let lastTimeStampString = (
                try? NSRegularExpression(pattern: "(?:(\\d+):)?(\\d+):([\\d\\.]+)")
                    .matches(
                        in: vttString,
                        range: .init(location: 0, length: vttString.utf16.count)
                    )
                    .last
                    .flatMap { Range($0.range, in: vttString) }
                    .flatMap { String(vttString[$0]) }
            ) ?? "0.000"
            
            let duration = lastTimeStampString.components(separatedBy: ":").reversed()
                .compactMap { Double($0) }
                .enumerated()
                .map { pow(60.0, Double($0.offset)) * $0.element }
                .reduce(0, +)
            
            let m3u8Subtitle = """
            #EXTM3U
            #EXT-X-VERSION:3
            #EXT-X-MEDIA-SEQUENCE:1
            #EXT-X-PLAYLIST-TYPE:VOD
            #EXT-X-ALLOW-CACHE:NO
            #EXT-X-TARGETDURATION:\(Int(duration))
            #EXTINF:\(String(format: "%.3f", duration)), no desc
            \(self.subtitleBundles[0].subtitleDTO.url)
            #EXT-X-ENDLIST
            """
            
            let m3u8Data = m3u8Subtitle.data(using: .utf8) ?? .init()
            
            loadingRequest.dataRequest?.respond(with: m3u8Data)
            
            loadingRequest.contentInformationRequest?.contentType = "public.m3u-playlist"
            loadingRequest.contentInformationRequest?.contentLength = Int64(m3u8Data.count)
            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
            
            loadingRequest.finishLoading()
        }
        task.resume()
        return true
    }
    
    func addSubs(to m3u8String: String) -> String {
        var lines = m3u8String.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        var lastPositionMedia: Int?
        var firstPositionInf = 1
        
        for (idx, line) in lines.enumerated() {
            if line.hasPrefix("#EXT-X-STREAM-INF") {
                firstPositionInf = idx
                break
            } else if line.hasPrefix("#EXT-X-MEDIA") {
                lastPositionMedia = idx + 1
            }
        }
        
        var subtitlePosition = lastPositionMedia ?? firstPositionInf
        
        for (idx, subtitle) in self.subtitleBundles.enumerated() {
            let m3u8Subtitles: OrderedDictionary = [
                "TYPE": "SUBTITLES",
                "GROUP-ID": "\"\(InterceptingAssetResourceLoaderDelegate.hlsSubtitleGroupID)\"",
                "NAME": "\"\(subtitle.subtitleDTO.language)\"",
                "CHARACTERISTICS": "\"public.accessibility.transcribes-spoken-dialog\"",
                "DEFAULT": subtitle.subtitleDTO.language.contains("English") ? "YES" : "NO",
                "AUTOSELECT": subtitle.subtitleDTO.language.contains("English") ? "YES" : "NO",
                "FORCED": subtitle.subtitleDTO.language.contains("English") ? "YES" : "NO",
                "URI": "\"\(InterceptingAssetResourceLoaderDelegate.subtitleUrlPrefix)://\(idx).subtitle.m3u8\"",
                "LANGUAGE": "\"\(subtitle.subtitleDTO.language)\""
            ]
            
            let m3u8SubtitlesString = "#EXT-X-MEDIA:" + m3u8Subtitles.map { "\($0.key)=\($0.value)" }
                .joined(separator: ",")
            if subtitlePosition <= lines.endIndex {
                lines.insert(m3u8SubtitlesString, at: subtitlePosition)
            } else {
                lines.append(m3u8SubtitlesString)
            }
            subtitlePosition += 1
        }
        
        for (idx, line) in lines.enumerated() where line.contains("#EXT-X-STREAM-INF") {
            lines[idx] = line + "," + "SUBTITLES=\"\(Self.hlsSubtitleGroupID)\""
        }
        
        return lines.joined(separator: "\n")
    }
    
    private func makePlaylistAndFragments(bundle: SubtitleBundle, subtitle: String) {
        let lastTimeStampString = (
            try? NSRegularExpression(pattern: "(?:(\\d+):)?(\\d+):([\\d\\.]+)")
                .matches(
                    in: subtitle,
                    range: .init(location: 0, length: subtitle.utf16.count)
                )
                .last
                .flatMap { Range($0.range, in: subtitle) }
                .flatMap { String(subtitle[$0]) }
        ) ?? "0.000"
        
        let duration = lastTimeStampString.components(separatedBy: ":").reversed()
            .compactMap { Double($0) }
            .enumerated()
            .map { pow(60.0, Double($0.offset)) * $0.element }
            .reduce(0, +)
        
        let m3u8Subtitle = """
        #EXTM3U
        #EXT-X-VERSION:3
        #EXT-X-MEDIA-SEQUENCE:1
        #EXT-X-PLAYLIST-TYPE:VOD
        #EXT-X-ALLOW-CACHE:NO
        #EXT-X-TARGETDURATION:\(Int(duration))
        #EXTINF:\(String(format: "%.3f", duration)), no desc
        \(bundle.subtitleDTO.url)
        #EXT-X-ENDLIST
        """
        
        bundle.playlist = m3u8Subtitle
    }
}
