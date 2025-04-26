import { useEvent } from "expo";
import ExpoVlcPlayer, { ExpoVlcPlayerView } from "expo-vlc-player";
import React from "react";
import { useState } from "react";
import { Button, useWindowDimensions, View } from "react-native";
import * as ScreenOrientation from "expo-screen-orientation";

export default function App() {
  const { width, height } = useWindowDimensions();
  const isLandScape = width > height;
  const [source, setSource] = useState(
    "https://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4"
  );

  const [pause, setPause] = useState(false);
  const [playbackRate, setPlaybackRate] = useState(1);
  const [seek, setSeek] = useState(0);

  const [isFull, setIsFull] = useState(true);

  const toggleFull = async () => {
    await ScreenOrientation.unlockAsync();
    if (isLandScape) {
      await ScreenOrientation.lockAsync(
        ScreenOrientation.OrientationLock.PORTRAIT_UP
      );
    } else {
      await ScreenOrientation.lockAsync(
        ScreenOrientation.OrientationLock.LANDSCAPE_LEFT
      );
    }
  };

  return (
    <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
      <ExpoVlcPlayerView
        source={source}
        style={{ width: "100%", height: "100%" }}
        pause={pause}
        playbackRate={playbackRate}
        seek={seek}
        // onLoad={({ nativeEvent }) => {
        //   console.log(nativeEvent, "load");
        // }}
        onProgress={({ nativeEvent }) => {
          // console.log(nativeEvent, "progress");
        }}
        startTime={30}
        metadata={{
          title: "Big Buck Bunny",
          artist: "The Open Movie Project",
        }}
        // onNetworkSpeedChange={({ nativeEvent }) => {
        //   console.log(nativeEvent, "networkSpeedChange");
        // }}
        // onOpen={({ nativeEvent }) => {
        //   console.log(nativeEvent, "open");
        // }}
        // onBuffering={({ nativeEvent }) => {
        //   console.log(nativeEvent, "buffering");
        // }}
        onStartPlaying={({ nativeEvent }) => {
          console.log(nativeEvent, "startPlaying");
        }}
      />
      <View style={{ position: "absolute", bottom: 0, left: 0, right: 0 }}>
        <Button title={`full`} onPress={toggleFull} />
        <Button
          title="Change source"
          onPress={() => {
            setSource(
              source ===
                "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                ? "https://looking.bigmelook.com/emby/videos/1759980/original.mkv?DeviceId=602ceccf-e89f-4712-bdc4-0eb2b66af79a&MediaSourceId=b8b559a88b63614a57d69c238c99a095&PlaySessionId=d0cd204b55714c118d7d75314c975b57&api_key=0d5b7b2cadf7414e90fe6180f95e6fb7"
                : "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
            );
          }}
        />
      </View>
    </View>
  );
}
