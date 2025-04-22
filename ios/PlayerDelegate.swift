//
//  PlayerDelegate.swift
//  Pods
//
//  Created by snow lee on 2025/4/22.
//
import VLCKit

extension VLCPlayerViewController : VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ newState: VLCMediaPlayerState) {
        // 使用 guard let 安全解包可选值
        guard let state = mediaPlayer?.state else {
            print("Media player state is nil")
            return
        }

        // 使用 switch 语句处理状态
     switch state {
        case .buffering:
            print("Media player is buffering...")
        case .playing:
            print("Media player is playing...")
        case .paused:
            print("Media player is paused.")
        case .stopping:
            print("Media player has ended.")
        case .error:
            print("Media player encountered an error.")
        default:
            print("Unknown media player state: \(state)")
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        let currentTime = mediaPlayer?.time.intValue
        let remainingTime = mediaPlayer?.remainingTime?.intValue
        let payload: [String: Int32?] = [
            "currentTime": currentTime,
            "remainingTime": remainingTime
        ]
        self.onProgress(payload)
    }
}

