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
public struct OnLoadEventPayload {
    let duration: Double
    let videoSize: [String: Double]
    let audioTracks: [Track]
    let textTracks: [Track]
}

class VLCPlayerViewController: UIViewController {
    public var mediaPlayer: VLCMediaPlayer?
    private var currentURL: URL?
    public var artworkDataTask: URLSessionDataTask?
    public var isScreenFilled: Bool = false
    public var metadata: VideoMetadata?

    let onLoad: ([String: Any]) -> Void
    let onProgress: ([String: Int32]) -> Void
    let onBuffering: ([String: Any]) -> Void
    let onOpen:([String: Any]) -> Void
    let onNetworkSpeedChange: ([String: Any]) -> Void
    let onStartPlaying: ([String: Any]) -> Void
    let onEnded: ([String: Any]) -> Void

    // 添加 videoOutputView 作为视频输出容器
    private let videoOutputView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        onVideoLoad: @escaping ([String: Any]) -> Void,
        onVideoProgress: @escaping ([String: Int32]) -> Void,
        onVideoBuffering:@escaping ([String: Any]) -> Void,
        onVideoOpen:@escaping ([String: Any]) -> Void,
        onVideoNetworkSpeedChange:@escaping ([String: Any]) -> Void,
        onVideoStartPlaying:@escaping ([String: Any]) -> Void,
        onVideoEnded:@escaping ([String: Any]) -> Void
    ) {
        self.onLoad = onVideoLoad
        self.onProgress = onVideoProgress
        self.onBuffering = onVideoBuffering
        self.onOpen = onVideoOpen
        self.onNetworkSpeedChange = onVideoNetworkSpeedChange
        self.onStartPlaying = onVideoStartPlaying
        self.onEnded = onVideoEnded
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.isUserInteractionEnabled = false

        // 将 videoOutputView 添加到视图层次结构中
        self.view.addSubview(videoOutputView)

        // 设置 videoOutputView 的约束，填满整个视图
        NSLayoutConstraint.activate([
            videoOutputView.topAnchor.constraint(equalTo: self.view.topAnchor),
            videoOutputView.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor),
            videoOutputView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor),
            videoOutputView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor),
        ])

    }

    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
     
        coordinator.animate(alongsideTransition: { _ in
            if self.isScreenFilled {
                self.fillScreen(screenSize: size)
            } 
        }, completion: nil)
    
        super.viewWillTransition(to: size, with: coordinator)
    }

    func playSource(url: URL) {
        guard url != currentURL else { return }
        if mediaPlayer?.media != nil {
            self.cleanUpPlayer()
        }
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.media = VLCMedia(url: url)
        mediaPlayer?.delegate = self
        mediaPlayer?.media?.delegate = self
        mediaPlayer?.timeChangeUpdateInterval = 0.3
        mediaPlayer?.drawable = self.videoOutputView
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation)
        mediaPlayer?.play()
        currentURL = url
    }

    func playAndPause(pause: Bool) {
        pause ? mediaPlayer?.pause() : mediaPlayer?.play()
    }

    func changePlaybackRate(rate: Float) {
        guard rate != mediaPlayer?.rate else { return }
        mediaPlayer?.rate = rate
    }

    func seekTime(time: Int64) {
        guard let player = mediaPlayer else {
            print("Media player is not initialized.")
            return
        }
        // 检查播放器状态是否允许跳转
        if player.isSeekable {
            // 1. 创建 VLCTime 对象，值为毫秒数
            let targetTimeInMilliseconds: Int64 = time * 1000 // 设置为 30 秒
            let timeToSet = VLCTime(number: NSNumber(value: targetTimeInMilliseconds))
            player.time = timeToSet
      
        }
    }

    func setAudioTackAtIndex(index: Int32) {
        let trackIndex = UInt(index)
        if let player = mediaPlayer {
            let audioTracks = player.audioTracks
            let count = audioTracks.count
            if trackIndex >= 0 && trackIndex < count {
                let track = audioTracks[Int(trackIndex)]
                track.isSelectedExclusively = true
            }
        }
    }

    func setTextTackAtIndex(index: Int32) {
        let trackIndex = UInt(index)
        if let player = mediaPlayer {
            let textTracks = player.textTracks
            let count = textTracks.count
            if trackIndex >= 0 && trackIndex < count {
                let track = textTracks[Int(trackIndex)]
                track.isSelectedExclusively = true
            }
        }
    }

    func toggleFillScreen(isFull: Bool) {
        isScreenFilled = isFull
        isFull ? fillScreen() : shrinkScreen()
    }

    func fillScreen(
        screenSize: CGSize = UIScreen.main.bounds.size
    ) {
        if let videoSize = mediaPlayer?.videoSize {

            let fillSize = CGSize.aspectFill(
                aspectRatio: videoSize, minimumSize: screenSize)

            let scale: CGFloat

            if fillSize.height > screenSize.height {
                scale = fillSize.height / screenSize.height
            } else {
                scale = fillSize.width / screenSize.width
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.videoOutputView.transform = CGAffineTransform(
                        scaleX: scale, y: scale)
                }
            }
        }
    }

    func shrinkScreen() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.videoOutputView.transform = .identity
            }

        }
    }

    func cleanUpPlayer() {
        print("VLCPlayerViewController deinit called")
        mediaPlayer?.delegate = nil
        mediaPlayer?.drawable = nil

        if mediaPlayer?.media != nil {
            mediaPlayer?.media?.delegate = nil
            mediaPlayer?.pause()
            mediaPlayer?.stop()
        }
        mediaPlayer = nil
        metadata = nil
        currentURL = nil
        artworkDataTask?.cancel()
        artworkDataTask = nil
    }

    deinit {
       self.cleanUpPlayer()
    }

}

extension CGSize {
    static func Circle(radius: CGFloat) -> CGSize {
        CGSize(width: radius, height: radius)
    }

    static func aspectFill(aspectRatio: CGSize, minimumSize: CGSize) -> CGSize {
        var minimumSize = minimumSize
        let mW = minimumSize.width / aspectRatio.width
        let mH = minimumSize.height / aspectRatio.height

        if mH > mW {
            minimumSize.width =
                minimumSize.height / aspectRatio.height * aspectRatio.width
        } else if mW > mH {
            minimumSize.height =
                minimumSize.width / aspectRatio.width * aspectRatio.height
        }

        return minimumSize
    }
}
