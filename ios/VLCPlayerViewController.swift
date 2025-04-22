//
//  VLCPlayerViewController.swift
//  Pods
//
//  Created by snowlee on 4/21/25.
//

import AVFoundation
import UIKit
import VLCKit

class VLCPlayerViewController: UIViewController, VLCMediaPlayerDelegate {
    public var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
    private var currentURL: URL?
    private var mediaDelegate: MediaDelegate?
    public var onLoadCallback: (([String: Any]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }

    private func setupPlayer() {
        mediaPlayer.drawable = self.view
        mediaPlayer.delegate = self
        mediaDelegate = MediaDelegate(mediaPlayer: mediaPlayer)

        self.view.backgroundColor = .black
        self.view.isUserInteractionEnabled = false
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation)
    }

    func playSource(_url: URL) {
        guard _url != currentURL else { return }  // 如果是相同地址就不重复播放

        mediaPlayer.media = VLCMedia(url: _url)
        mediaDelegate?.updateMediaDelegate(for: mediaPlayer.media)
        mediaPlayer.play()

        // 设置超时时间（单位：毫秒）
        let timeoutValue: Int32 = 10000
        // 设置解析选项
        let withoptions: VLCMediaParsingOptions = [
            .parseLocal, .parseNetwork, .fetchNetwork, .doInteract,
        ]

        mediaPlayer.media?.parse(options: withoptions, timeout: timeoutValue)
        currentURL = _url
    }


    deinit {
        mediaPlayer.stop()
        currentURL = nil
        mediaPlayer.media?.delegate = nil
        mediaPlayer.delegate = nil
        mediaPlayer.drawable = nil

    }

}
