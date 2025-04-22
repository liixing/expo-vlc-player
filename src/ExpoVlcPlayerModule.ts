import { NativeModule, requireNativeModule } from "expo";

import { ExpoVlcPlayerModuleEvents } from "./ExpoVlcPlayer.types";

declare class ExpoVlcPlayerModule extends NativeModule<ExpoVlcPlayerModuleEvents> {
  isPictureInPictureSupported(): Promise<boolean>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoVlcPlayerModule>("ExpoVlcPlayer");
