import ExpoModulesCore
import WebKit

// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
class ExpoVlcPlayerView: ExpoView {
    private var playerViewController: VLCPlayerViewController!

    @objc var source: URL = URL(string: "about:blank")! {
      didSet {
        playerViewController.playSource(url: source)
      }
    }

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
      playerViewController = VLCPlayerViewController()
      playerViewController.view.frame = self.bounds
      playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.addSubview(playerViewController.view)
  }

    override func layoutSubviews() {
      super.layoutSubviews()
      playerViewController.view.frame = self.bounds
    }
}

