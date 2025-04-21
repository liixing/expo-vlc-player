//
//  VLCPlayerViewController.swift
//  Pods
//
//  Created by snowlee on 4/21/25.
//

import UIKit
import VLCKit
import AVFoundation
import CommonCrypto

class VLCPlayerViewController: UIViewController, VLCMediaPlayerDelegate,VLCMediaDelegate {
  private var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
  private var currentURL: URL?
  private var metadata: VLCMedia.MetaData?

 
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
    
  func playSource(_url: URL) {
    guard _url != currentURL else { return } // 如果是相同地址就不重复播放

    mediaPlayer.media = VLCMedia(url: _url)
    mediaPlayer.media?.delegate = self

    // 设置超时时间（单位：毫秒）
    let timeoutValue: Int32 = 10000
      // 设置解析选项
    let withoptions: VLCMediaParsingOptions = [.parseLocal, .parseNetwork, .fetchNetwork, .doInteract]
      
    mediaPlayer.media?.parse(options: withoptions, timeout: timeoutValue)
    currentURL = _url

   
    mediaPlayer.play()
  }

    

  func mediaDidFinishParsing(_ aMedia: VLCMedia) {
//      setNeedsMetadataUpdate()
  }
    
//    func setNeedsMetadataUpdate() {
//        #if os(tvOS)
//        metadata.updateMetadata(fromMediaPlayer: mediaPlayer)
//        #else
//        let media = mediaPlayer.media != nil ? VLCMLMedia.media(forPlayingMedia: mediaPlayer.media!) : nil
//        metadata?.updateMetadata(fromMedia: media, mediaPlayer: mediaPlayer)
//        #endif
//
//        recoverDisplayedMetadata()
//    }


  func stopPlayback() {
    mediaPlayer.stop()
    currentURL = nil
  }

  deinit {
    mediaPlayer.stop()
    mediaPlayer.delegate = nil
    mediaPlayer.drawable=nil
  }
}
