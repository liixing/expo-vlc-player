import ExpoModulesCore
import VLCKit
import WebKit

// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
class ExpoVlcPlayerView: ExpoView {
    public var playerViewController: VLCPlayerViewController!

    let onLoad = EventDispatcher()
    let onBuffering = EventDispatcher()
    let onProgress = EventDispatcher()

    @objc var source: URL = URL(string: "about:blank")! {
        didSet {
            playerViewController.playSource(url: source)
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
            print("seek updated to: \(seek)")
            playerViewController.seekTime(time: seek)
        }
    }
    
    

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        playerViewController = VLCPlayerViewController(
            onVideoLoad: { [weak self] payload in
                self?.onLoad(payload)
            },
            onVideoBuffering: { [weak self] payload in
                self?.onBuffering(payload)
            },
            onVideoProgress: { [weak self] payload in
                self?.onProgress(payload)
            }
        )
        playerViewController.view.frame = self.bounds
        playerViewController.view.autoresizingMask = [
            .flexibleWidth, .flexibleHeight,
        ]
        self.addSubview(playerViewController.view)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerViewController.view.frame = self.bounds
    }
}
