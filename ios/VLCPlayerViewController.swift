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

class VLCPlayerViewController: UIViewController {
    public var mediaPlayer: VLCMediaPlayer?
    private var currentURL: URL?
    public var artworkDataTask: URLSessionDataTask?

    let onLoad: ([String: Any]) -> Void
    let onBuffering: ([String: Any]) -> Void
    let onProgress: ([String: Any]) -> Void

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        onVideoLoad: @escaping ([String: Any]) -> Void,
        onVideoBuffering: @escaping ([String: Any]) -> Void,
        onVideoProgress: @escaping ([String: Any]) -> Void
    ) {
        self.onLoad = onVideoLoad
        self.onBuffering = onVideoBuffering
        self.onProgress = onVideoProgress
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.isUserInteractionEnabled = false
    }

    func playSource(url: URL) {
        guard url != currentURL else { return }
        if mediaPlayer != nil {
            self.release()
        }
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.media = VLCMedia(url: url)
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
        currentURL = url
    }

    func playAndPause(pause: Bool) {
        pause ? mediaPlayer?.pause() : mediaPlayer?.play()
    }
    
    func changePlaybackRate(rate:Float){
        guard rate != mediaPlayer?.rate else { return }
        mediaPlayer?.rate = rate
    }
    
    func seekTime(time:Float){
        print(time,"seek")
        guard time > 0.0, let player = mediaPlayer, player.isSeekable else {
            return
        }
        let seekTime = Int32 (time * 1000 )
       
        player.time = VLCTime(int:seekTime)
    }

    func release() {
        if mediaPlayer != nil {
            mediaPlayer?.pause()
            currentURL = nil
            mediaPlayer?.media?.delegate = nil
            mediaPlayer?.delegate = nil
            mediaPlayer?.drawable = nil
        }
    }

    deinit {
        self.release()
    }

}
