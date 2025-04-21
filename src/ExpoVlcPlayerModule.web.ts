import { registerWebModule, NativeModule } from 'expo';

import { ExpoVlcPlayerModuleEvents } from './ExpoVlcPlayer.types';

class ExpoVlcPlayerModule extends NativeModule<ExpoVlcPlayerModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoVlcPlayerModule);
