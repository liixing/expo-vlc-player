import ExpoModulesCore
import VLCKit
import WebKit
import React

// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
class ExpoVlcPlayerView: ExpoView {
    public var playerViewController: VLCPlayerViewController!

    let onLoad = EventDispatcher()
    let onPlayingChange = EventDispatcher()
    let onProgress = EventDispatcher()
    let onEnd = EventDispatcher()

    @objc var source: URL = URL(string: "about:blank")! {
        didSet {
            playerViewController.playSource(url: source)
            playerViewController.updateMetaData()
        }
    }
    
    @objc var pause: Bool = false {
        didSet {
            playerViewController.playAndPause(pause: pause)
        }
    }
    
    @objc var playbackRate:Float = 1{
        didSet{
            playerViewController.changePlaybackRate(rate: playbackRate)
        }
    }
    
    @objc var seek: Float = 0.0{
        didSet{
            playerViewController.seekTime(time: seek)
        }
    }
    
    
    @objc var audioTrackIndex: Int32 = -2 {
        didSet{
            playerViewController.setAudioTackAtIndex(index: audioTrackIndex)
        }
    }
    
    @objc var textTrackIndex: Int32 = -2 {
        didSet{
            playerViewController.setTextTackAtIndex(index: textTrackIndex)
        }
    }
    
    @objc var isFillScreen: Bool = false {
        didSet {
            playerViewController.toggleFillScreen(isFull: isFillScreen)
            playerViewController.isScreenFilled = isFillScreen
        }
    }
    
    

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        playerViewController = VLCPlayerViewController(
            onVideoLoad: { [weak self] payload in
                self?.onLoad(payload)
            },
            onVideoPlayingChange: { [weak self] (payload:[String:Bool]) in
                self?.onPlayingChange(payload)
            },
            onVideoProgress: { [weak self] (payload:[String:Int32]) in
                self?.onProgress(payload)
            },
            onVideoEnd: { [weak self] payload in
                self?.onEnd(payload)
            }
        )
      
        playerViewController.view.frame = self.bounds
        playerViewController.view.autoresizingMask = [
            .flexibleWidth, .flexibleHeight,
        ]
        self.addSubview(playerViewController.view)
        // 获取当前呈现的 UIViewController
        if let presentedViewController = RCTPresentedViewController() {
            print("[VLCPlayer][Init] 找到 Controller")
            presentedViewController.addChild(playerViewController)
            playerViewController.didMove(toParent: presentedViewController)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerViewController.view.frame = self.bounds
    }
    
    deinit {
        print("ExpoVlcPlayerView deinit called")
        playerViewController.willMove(toParent: nil)
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()
        self.playerViewController = nil
     
    }
    
}
