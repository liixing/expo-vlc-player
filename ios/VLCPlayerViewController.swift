//
//  VLCPlayerViewController.swift
//  Pods
//
//  Created by snowlee on 4/21/25.
//

import UIKit
import VLCKit
import AVFoundation

class VLCPlayerViewController: UIViewController, VLCMediaPlayerDelegate{
  private var mediaPlayer: VLCMediaPlayer!
    
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  func playSource(url: URL) {
      if(mediaPlayer != nil){
          cleanupPlayer()
      }

      mediaPlayer = VLCMediaPlayer()

      mediaPlayer.drawable = self.view
      mediaPlayer.delegate = self
      mediaPlayer.media = VLCMedia.init(url: url)
      
      mediaPlayer.play()
      

      self.view.backgroundColor = .black
      self.view.isUserInteractionEnabled=false

    try? AVAudioSession.sharedInstance().setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
  }
    
    func cleanupPlayer(){
        if(mediaPlayer != nil){
            mediaPlayer.pause()
            mediaPlayer = nil
            
        }
    }
    
}
