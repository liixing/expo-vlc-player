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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(onVideoLoad: @escaping ([String: Any]) -> Void, onVideoBuffering: @escaping ([String: Any]) -> Void) {
        self.onLoad = onVideoLoad
        self.onBuffering = onVideoBuffering
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

    func release(){
        if(mediaPlayer != nil){
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



