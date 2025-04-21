import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoVlcPlayerViewProps } from './ExpoVlcPlayer.types';

const NativeView: React.ComponentType<ExpoVlcPlayerViewProps> =
  requireNativeView('ExpoVlcPlayer');

export default function ExpoVlcPlayerView(props: ExpoVlcPlayerViewProps) {
  return <NativeView {...props} />;
}
