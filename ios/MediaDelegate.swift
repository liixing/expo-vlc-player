//
//  MediaDelegate.swift
//  Pods
//
//  Created by snow lee on 2025/4/22.
//

import MediaPlayer
import VLCKit

extension VLCPlayerViewController: VLCMediaDelegate {

    @objc func mediaDidFinishParsing(_ aMedia: VLCMedia) {
        updateMetaData(Media: aMedia)
    }

    @objc func mediaMetaDataDidChange(_ aMedia: VLCMedia) {
        updateMetaData(Media: aMedia)
        loadVideoInfo(for: aMedia)
    }

    func loadVideoInfo(for media: VLCMedia) {
        if mediaPlayer?.audioTracks.count == 0 {
            return
        }
        let duration = Double(media.length.intValue)
        var audioTracks: [Track] = []
        var textTracks: [Track] = []

        // 获取音频轨道
        if let audotracks = mediaPlayer?.audioTracks, audotracks.count > 0 {
            for (index, track) in audotracks.enumerated() {
                let newTrack = Track(
                    id: index,
                    name: track.trackName,
                    isSelected: track.isSelectedExclusively
                )
                audioTracks.append(newTrack)
            }
        }

        // 获取字幕轨道
        if let texttracks = mediaPlayer?.textTracks, texttracks.count > 0 {
            for (index, track) in texttracks.enumerated() {
                let newTrack = Track(
                    id: index,
                    name: track.trackName,
                    isSelected: track.isSelectedExclusively
                )
                textTracks.append(newTrack)
            }
        }

        let videoSize: [String: Double] = [
            "width": Double(mediaPlayer?.videoSize.width ?? 0),
            "height": Double(mediaPlayer?.videoSize.height ?? 0),
        ]

        let payload: [String: Any] = [
            "duration": duration,
            "videoSize": videoSize,
            "audioTracks": audioTracks.map {
                [
                    "id": $0.id,
                    "name": $0.name,
                    "isSelected": $0.isSelected,
                ]
            },
            "textTracks": textTracks.map {
                [
                    "id": $0.id,
                    "name": $0.name,
                    "isSelected": $0.isSelected,
                ]
            },
        ]

        self.onLoad(payload)
        self.toggleFillScreen(isFull: isScreenFilled)
    }

    func updateMetaData(Media: VLCMedia) {
        var nowPlayingInfo =
            MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        let title = Media.metaData.title
        let artist = Media.metaData.artist
        let duration = Media.length.value
        let elapsedPlaybackTime = (mediaPlayer?.time.intValue ?? 0) / 1000

        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] =
            elapsedPlaybackTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = mediaPlayer?.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] =
            MPNowPlayingInfoMediaType.video.rawValue
        if let artworkUrl = Media.metaData.artworkURL,
            artworkDataTask?.originalRequest?.url != artworkUrl
        {
            artworkDataTask?.cancel()
            artworkDataTask = fetchArtwork(url: artworkUrl) { artwork in
                if let artwork = artwork {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                }
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

private func fetchArtwork(
    url: URL, completion: @escaping (MPMediaItemArtwork?) -> Void
) -> URLSessionDataTask {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching artwork: \(error)")
            completion(nil)
            return
        }
        guard let data = data, response is HTTPURLResponse else {
            completion(nil)
            return
        }

        if let image = UIImage(data: data) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
            completion(artwork)
        } else {
            completion(nil)
        }
    }
    task.resume()  // 确保任务开始执行
    return task
}
