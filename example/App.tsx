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

  return (
    <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
      <ExpoVlcPlayerView
        source={source}
        style={{ width: "100%", height: "100%" }}
        onLoad={(videoInfo) => {
          console.log(videoInfo);
        }}
      />
      <View style={{ position: "absolute", bottom: 0, left: 0, right: 0 }}>
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
