import ExpoModulesCore

public class ExpoVlcPlayerModule: Module {
    // Each module class must implement the definition function. The definition consists of components
    // that describes the module's functionality and behavior.
    // See https://docs.expo.dev/modules/module-api for more details about available components.
    public func definition() -> ModuleDefinition {
        // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
        // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
        // The module will be accessible from `requireNativeModule('ExpoVlcPlayer')` in JavaScript.
        Name("ExpoVlcPlayer")

        Function("isPictureInPictureSupported") { () -> Bool in
            return AVPictureInPictureController.isPictureInPictureSupported()
        }

        // Enables the module to be used as a native view. Definition components that are accepted as part of the
        // view definition: Prop, Events.
        View(ExpoVlcPlayerView.self) {
            // Defines a setter for the `url` prop.
            Prop("source") { (view: ExpoVlcPlayerView, source: URL) in
                if view.source != source {
                    view.source = source
                }
            }

            Prop("pause") { (view: ExpoVlcPlayerView, pause: Bool) in
                if view.pause != pause {
                    view.pause = pause
                }
            }

            Prop("playbackRate") {
                (view: ExpoVlcPlayerView, playbackRate: Float) in
                if view.playbackRate != playbackRate {
                    view.playbackRate = playbackRate
                }
            }
            
            Prop("seek"){
              (view: ExpoVlcPlayerView, seek: Float) in
                if view.seek != seek {
                    view.seek = seek
                }
            }

            Events("onLoad", "onBuffering", "onProgress")
        }
    }
}
