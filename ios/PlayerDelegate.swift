//
//  PlayerDelegate.swift
//  Pods
//
//  Created by snow lee on 2025/4/22.
//
import MobileVLCKit

extension VLCPlayerViewController: VLCMediaPlayerDelegate {

    func mediaPlayerStateChanged(_ aNotification: Notification) {
        // 使用 guard let 安全解包可选值
        guard let state = mediaPlayer?.state else {
            print("Media player state is nil")
            return
        }

        // 使用 switch 语句处理状态
        switch state {
        case .opening:
            updateNetworkSpeed()
            self.onOpen(["open": true])
            break
        case .buffering:
            updateNetworkSpeed()
            self.onBuffering(["buffering": true])
            if videoInfo == nil {
                loadVideoInfo()
            }
            break
        case .playing:
            updateNetworkSpeed()
            seekByStartTime()
            print("playing------------")
            break
        case .paused:
            break
        case .stopped:
            self.onEnded(["ended": true])
            break
        case .error:
            print("Media player encountered an error.")
            break
        default:
            print("Unknown media player state: \(state)")
        }
    }

    func seekByStartTime() {
        if startTime > 0 {
            seekTime(time: startTime)
        }
    }

    func loadVideoInfo() {
        if mediaPlayer?.numberOfAudioTracks ?? 0 <= 0 {
            return
        }
        let duration = Double(mediaPlayer?.media?.length.intValue ?? 0)

        var textTracks: [Track] = []

        var audioTracks: [Track] = []
        // 获取音频轨道
        if let player = mediaPlayer, player.numberOfAudioTracks > 0 {
            if let trackIndexes = player.audioTrackIndexes as? [NSNumber],
                let trackNames = player.audioTrackNames as? [String],
                trackIndexes.count == trackNames.count
            {
                for i
                    in 0..<min(
                        trackIndexes.count, Int(player.numberOfAudioTracks))
                {
                    let trackIndex = trackIndexes[i]
                    let trackName = trackNames[i]
                    let isSelected =
                        player.currentAudioTrackIndex == trackIndex.intValue
                    audioTracks.append(
                        Track(
                            id: trackIndex.intValue, name: trackName,
                            isSelected: isSelected))
                }
            }
        }

        // 获取字幕轨道
        if let player = mediaPlayer, player.numberOfSubtitlesTracks > 0 {
            if let subtitleIndexes = player.videoSubTitlesIndexes
                as? [NSNumber],
                let subtitleNames = player.videoSubTitlesNames as? [String],
                subtitleIndexes.count == subtitleNames.count
            {
                for i
                    in 0..<min(
                        subtitleIndexes.count,
                        Int(player.numberOfSubtitlesTracks))
                {
                    let subtitleIndex = subtitleIndexes[i]
                    let subtitleName = subtitleNames[i]
                    let isSelected =
                        player.currentVideoSubTitleIndex
                        == subtitleIndex.intValue
                    textTracks.append(
                        Track(
                            id: subtitleIndex.intValue, name: subtitleName,
                            isSelected: isSelected))
                }
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
        videoInfo = payload
        self.toggleFillScreen(isFull: isScreenFilled)
    }

    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        let currentTime = mediaPlayer?.time.intValue ?? 0
        let remainingTime = mediaPlayer?.remainingTime?.intValue ?? 0
        let payload: [String: Int32] = [
            "currentTime": currentTime,
            "remainingTime": remainingTime,
        ]
        self.onProgress(payload)
        updateNetworkSpeed()
    }

    func updateNetworkSpeed() {
        if let stats = mediaPlayer?.media?.statistics {
            self.onNetworkSpeedChange(["speed": stats.inputBitrate])
        }
    }
}
