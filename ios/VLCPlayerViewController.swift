//
//  VLCPlayerViewController.swift
//  Pods
//
//  Created by snowlee on 4/21/25.
//

import UIKit
import VLCKit
import AVFoundation

class VLCPlayerViewController: UIViewController, VLCMediaPlayerDelegate {
  private var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
  private var currentURL: URL?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupPlayer()
  }

  private func setupPlayer() {
    mediaPlayer.drawable = self.view
    mediaPlayer.delegate = self
    self.view.backgroundColor = .black
    self.view.isUserInteractionEnabled = false

    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  func playSource(url: URL) {
    guard url != currentURL else { return } // 如果是相同地址就不重复播放

    currentURL = url
    mediaPlayer.media = VLCMedia(url: url)
    mediaPlayer.play()
  }

  func stopPlayback() {
    mediaPlayer.stop()
    currentURL = nil
  }

  deinit {
    mediaPlayer.stop()
    mediaPlayer.delegate = nil
  }
}
