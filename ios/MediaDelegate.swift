//
//  MediaDelegate.swift
//  Pods
//
//  Created by snow lee on 2025/4/22.
//

import MediaPlayer
import MobileVLCKit

extension VLCPlayerViewController: VLCMediaDelegate {
    func updateMetaData() {
        var nowPlayingInfo =
            MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        let title = metadata?.title
        let artist = metadata?.artist
        let duration = mediaPlayer?.media?.length.value
        let elapsedPlaybackTime = (mediaPlayer?.time.intValue ?? 0) / 1000

        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] =
            elapsedPlaybackTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = mediaPlayer?.rate
//        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] =
//            MPNowPlayingInfoMediaType.video.rawValue
        if let artworkUrl = metadata?.artwork,
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
