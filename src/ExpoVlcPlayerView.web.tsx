import * as React from 'react';

import { ExpoVlcPlayerViewProps } from './ExpoVlcPlayer.types';

export default function ExpoVlcPlayerView(props: ExpoVlcPlayerViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
