//
//  PlayerDelegate.swift
//  Pods
//
//  Created by snow lee on 2025/4/22.
//
import VLCKit

extension VLCPlayerViewController: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ newState: VLCMediaPlayerState) {
        // 使用 guard let 安全解包可选值
        guard let state = mediaPlayer?.state else {
            print("Media player state is nil")
            return
        }

        // 使用 switch 语句处理状态
        switch state {
        case .buffering:
            self.onPlayingChange( ["isPlaying": false])
            break
        case .paused:
            self.onPlayingChange(["isPlaying": false])
            break
        case .stopped:
            break
        case .stopping:
            self.onPlayingChange(["isPlaying": false])
            self.onEnd(["isEnd": true])
            break
        case .error:
            print("Media player encountered an error.")
            break
        default:
            print("Unknown media player state: \(state)")
        }
    }

    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        let currentTime = mediaPlayer?.time.intValue ?? 0
        let remainingTime = mediaPlayer?.remainingTime?.intValue ?? 0
        let payload: [String: Int32] = [
            "currentTime": currentTime,
            "remainingTime": remainingTime,
        ]
        self.onProgress(payload)
    }
}
