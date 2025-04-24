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
    public var mediaPlayer: VLCMediaPlayer? = VLCMediaPlayer()
    private var currentURL: URL?
    public var artworkDataTask: URLSessionDataTask?
    public var isScreenFilled: Bool = false
    public var metadata: VideoMetadata?
    
    let onLoad: ([String: Any]) -> Void
    let onPlayingChange: ([String: Bool]) -> Void
    let onProgress: ([String: Int32]) -> Void
    let onEnd: ([String: Any]) -> Void
    
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
        onVideoPlayingChange: @escaping ([String: Bool]) -> Void,
        onVideoProgress: @escaping ([String: Int32]) -> Void,
        onVideoEnd: @escaping ([String: Any]) -> Void
    ) {
        self.onLoad = onVideoLoad
        self.onPlayingChange = onVideoPlayingChange
        self.onProgress = onVideoProgress
        self.onEnd = onVideoEnd
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
        if isScreenFilled {
            fillScreen(screenSize: size)
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func playSource(url: URL) {
        guard url != currentURL else { return }
        if mediaPlayer?.media != nil{
            self.cleanUpPlayer()
        }
        
        mediaPlayer?.media = VLCMedia(url: url)
        mediaPlayer?.delegate = self
        mediaPlayer?.media?.delegate = self
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
    
    func seekTime(time: Float) {
        guard time > 0.0 else {
            return
        }
        guard let player = mediaPlayer else {
            print("Media player is not initialized.")
            return
        }
        
        // 检查播放器状态是否允许跳转
        if player.isSeekable {
            let seekTime = Int32(time * 1000)
            player.time = VLCTime(int: seekTime)
            print("Seeking to time: \(seekTime) ms")
            
            // 如果播放器当前未播放，尝试重新播放
            if !player.isPlaying {
                player.play()
                print("Player was not playing, restarting playback after seek.")
            }
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
    
    func cleanUpPlayer(){
        mediaPlayer?.delegate = nil
        mediaPlayer?.drawable = nil

        if mediaPlayer?.media != nil {
            mediaPlayer?.media?.delegate = nil
            mediaPlayer?.pause()
            mediaPlayer?.stop()
        }
    }

    deinit {
        self.cleanUpPlayer()
        mediaPlayer = nil
        metadata = nil
        currentURL = nil
        artworkDataTask?.cancel()
        artworkDataTask = nil
     
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
