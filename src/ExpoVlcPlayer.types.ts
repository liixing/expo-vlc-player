import type { StyleProp, ViewStyle } from "react-native";

/**
 * Represents a track type in playback
 */
export type Track = {
  /**
   * Track identification
   */
  id: number;

  /**
   * Track name
   */
  name: string;

  /**
   * Whether the track is the selected track
   */
  isDefault: boolean;
};

export type OnLoadEventPayload = {
  /**
   * Total playback duration
   */
  duration: number;

  /**
   * Total playback video size
   */
  videoSize: Record<"width" | "height", number>;
  /**
   * List of playback audio tracks
   */
  audioTracks: Track[];
  /**
   * List of playback text tracks
   */
  textTracks: Track[];
};

export type OnProgressEventPayload = {
  currentTime: number;
  remainingTime: number;
};

export type ExpoVlcPlayerModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
};

export type ChangeEventPayload = {
  value: string;
};

export type ExpoVlcPlayerViewProps = {
  source: string;
  pause?: boolean;
  playbackRate?:number
  seek?:number
  style?: StyleProp<ViewStyle>;
  onLoad?: (event: { nativeEvent: OnLoadEventPayload }) => void;
  // onBuffering?: (event: { nativeEvent: OnBufferingEventPayload }) => void;
  onProgress?: (event: { nativeEvent: OnProgressEventPayload }) => void;
};
