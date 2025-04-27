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
  isSelected: boolean;
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

export type OnBufferingEventPayload = {
  isPlaying: boolean;
};

export type SimpleEventPayload = {
  target: number;
};

export type ExpoVlcPlayerModuleEvents = {
  isPictureInPictureSupported: () => Promise<boolean>;
};

/**
 * Contains information that will be displayed in the now playing notification when the video is playing.
 * @platform android
 * @platform ios
 */
export type VideoMetadata = {
  /**
   * The title of the video.
   * @platform android
   * @platform ios
   */
  title?: string;
  /**
   * Secondary text that will be displayed under the title.
   * @platform android
   * @platform ios
   */
  artist?: string;
  /**
   * The uri of the video artwork.
   * @platform android
   * @platform ios
   */
  artwork?: string;
};

export type OnNetworkSpeedChangeEventPayload = {
  speed: number;
};

export type ExpoVlcPlayerViewProps = {
  source: string;
  pause?: boolean;
  playbackRate?: number;
  seek?: number;
  metadata?: VideoMetadata;
  isFillScreen?: boolean;
  startTime?: number;
  style?: StyleProp<ViewStyle>;
  onLoad?: (event: { nativeEvent: OnLoadEventPayload }) => void;
  onBuffering?: (event: { nativeEvent: SimpleEventPayload }) => void;
  onProgress?: (event: { nativeEvent: OnProgressEventPayload }) => void;
  onNetworkSpeedChange?: (event: {
    nativeEvent: OnNetworkSpeedChangeEventPayload;
  }) => void;
  onOpen?: (event: { nativeEvent: SimpleEventPayload }) => void;
  onEnded?: (event: { nativeEvent: SimpleEventPayload }) => void;
  textTrackIndex?: number;
  audioTrackIndex?: number;
};
