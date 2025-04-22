import { useEvent } from "expo";
import ExpoVlcPlayer, { ExpoVlcPlayerView } from "expo-vlc-player";
import React from "react";
import { useState } from "react";
import { Button, View } from "react-native";

export default function App() {
  // const onChangePayload = useEvent(ExpoVlcPlayer, "onChange");
  const [source, setSource] = useState(
    "https://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4"
  );

  const [pause, setPause] = useState(false);
  const [playbackRate, setPlaybackRate] = useState(1);
  const [seek, setSeek] = useState(0);
  // const [currentTime, setCurrentTime] = useState(0);
  // const [duration, setDuration] = useState(0);

  // const currentTime = useSharedValue(0);

  // const onSeek = (time: number) => {
  //   // 确保 time 在 0 到 duration 之间
  //   const clampedTime = Math.max(0, Math.min(time, duration));
  //   setSeek(clampedTime);
  // };

  return (
    <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
      <ExpoVlcPlayerView
        source={source}
        style={{ width: "100%", height: "100%" }}
        // onLoad={({ nativeEvent }) => {
        //   setDuration(nativeEvent.duration / 1000);
        // }}
        // onProgress={({ nativeEvent }) => {
        //   setCurrentTime(nativeEvent.currentTime / 1000);
        // }}
        pause={pause}
        playbackRate={playbackRate}
        seek={seek}
      />
      <View style={{ position: "absolute", bottom: 0, left: 0, right: 0 }}>
        <Button title={`seek`} onPress={() => setSeek(30)} />
        <Button
          title="Change source"
          onPress={() => {
            setSource(
              source ===
                "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                ? "https://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4"
                : "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
            );
          }}
        />
      </View>
    </View>
  );
}
