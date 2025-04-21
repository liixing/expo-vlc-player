import { NativeModule, requireNativeModule } from 'expo';

import { ExpoVlcPlayerModuleEvents } from './ExpoVlcPlayer.types';

declare class ExpoVlcPlayerModule extends NativeModule<ExpoVlcPlayerModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoVlcPlayerModule>('ExpoVlcPlayer');
