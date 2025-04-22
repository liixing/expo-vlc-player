//
//  VLCPlayerViewController.swift
//  Pods
//
//  Created by snowlee on 4/21/25.
//

import AVFoundation
import MediaPlayer
import UIKit
import VLCKit

struct Track {
    let id: Int
    let name: String
    let isSelected: Bool
}
struct OnLoadEventPayload {
    let duration: Double
    let videoSize: [String: Double]
    let audioTracks: [Track]
    let textTracks: [Track]
}

class VLCPlayerViewController: UIViewController, VLCMediaDelegate,VLCMediaPlayerDelegate {
    public var mediaPlayer: VLCMediaPlayer?
    private var currentURL: URL?
    private var artworkDataTask: URLSessionDataTask?
    private var videoInfo: OnLoadEventPayload
    
    let onLoad: ([String: Any]) -> Void
    let onBuffering: ([String: Any]) -> Void
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(onVideoLoad: @escaping ([String: Any]) -> Void, onVideoBuffering: @escaping ([String: Any]) -> Void) {
        self.onLoad = onVideoLoad
        self.onBuffering = onVideoBuffering
        self.videoInfo = OnLoadEventPayload(
            duration: 0,
            videoSize: ["width": 0, "height": 0],
            audioTracks: [],
            textTracks: []
        )
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.isUserInteractionEnabled = false
    }


    func playSource(_url: URL) {
        guard _url != currentURL else { return }  // 如果是相同地址就不重复播放
        
        if(mediaPlayer != nil){
            self.release()
        }
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.media = VLCMedia(url: _url)
        mediaPlayer?.delegate = self
        mediaPlayer?.media?.delegate = self
        mediaPlayer?.drawable = self.view
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation)
        
        // 设置超时时间（单位：毫秒）
        let timeoutValue: Int32 = 10000
        // 设置解析选项
        let withoptions: VLCMediaParsingOptions = [
            .parseLocal, .parseNetwork, .fetchNetwork, .doInteract,
        ]
        
        mediaPlayer?.play()

        mediaPlayer?.media?.parse(options: withoptions, timeout: timeoutValue)
        currentURL = _url
    }


    func mediaDidFinishParsing(_ aMedia: VLCMedia?) {
        print("parsing....")
        if let media = aMedia {
            updateMetaData(Media: media)
//            loadVideoInfo(for: media)
        }
    }

    func mediaMetaDataDidChange(_ aMedia: VLCMedia?) {
        print("change....")
        if let media = aMedia {
            updateMetaData(Media: media)
            loadVideoInfo(for: media)
        }
    }

    func loadVideoInfo(for media: VLCMedia) {
        let duration = Double(media.length.intValue)
        var audioTracks: [Track] = []
        var textTracks: [Track] = []

        // 获取音频轨道
        if let tracks = mediaPlayer?.audioTracks, tracks.count > 0 {
            for (index, track) in tracks.enumerated() {
                if let track = track as? VLCMediaPlayer.Track {
                    let newTrack = Track(
                        id: index,
                        name: track.trackName,
                        isSelected: track.isSelectedExclusively
                    )
                    audioTracks.append(newTrack)
                }
            }
        }

        // 获取字幕轨道
        if let tracks = mediaPlayer?.textTracks, tracks.count > 0 {
            for (index, track) in tracks.enumerated() {
                if let track = track as? VLCMediaPlayer.Track {
                    let newTrack = Track(
                        id: index,
                        name: track.trackName,
                        isSelected: track.isSelectedExclusively
                    )
                    textTracks.append(newTrack)
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
            "audioTracks": audioTracks.map { [
                "id": $0.id,
                "name": $0.name,
                "isSelected": $0.isSelected
            ] },
            "textTracks": textTracks.map { [
                "id": $0.id,
                "name": $0.name,
                "isSelected": $0.isSelected
            ] }
        ]
        
        self.onLoad(payload)
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
    
    func release(){
        if(mediaPlayer != nil){
            mediaPlayer?.stop()
            currentURL = nil
            mediaPlayer?.media?.delegate = nil
            mediaPlayer?.delegate = nil
            mediaPlayer?.drawable = nil
        }
    }
    

    deinit {
     self.release()
    }

    func mediaPlayerStateChanged(_ aNotification: Notification?) {
        guard let player = aNotification?.object as? VLCMediaPlayer else { return }
        
        switch player.state {
        case .buffering:
            self.onBuffering(["isBuffering": true])
        case .playing:
            self.onBuffering(["isBuffering": false])
        default:
            break
        }
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
