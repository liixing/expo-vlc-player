import ExpoModulesCore
import VLCKit
import WebKit



// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
class ExpoVlcPlayerView: ExpoView {
    public var playerViewController: VLCPlayerViewController!
   
    let onLoad = EventDispatcher()
    let onBuffering = EventDispatcher()

    @objc var source: URL = URL(string: "about:blank")! {
        didSet {
            playerViewController.playSource(_url: source)
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


