//
//  MediaDelegate.swift
//  Pods
//
//  Created by snowlee on 4/22/25.
//
import VLCKit
import MediaPlayer

class MediaDelegate: NSObject, VLCMediaDelegate {
    private weak var mediaPlayer: VLCMediaPlayer?
    private var artworkDataTask: URLSessionDataTask?
    
    init(mediaPlayer: VLCMediaPlayer) {
        self.mediaPlayer = mediaPlayer
        super.init()
    }
    
    func updateMediaDelegate(for media: VLCMedia?) {
        media?.delegate = self
    }
    
    func mediaDidFinishParsing(_ aMedia: VLCMedia) {
        // 获取媒体元数据
        if(aMedia.metaData != nil){
            updateMetaData(Media:aMedia)
        }
    }
    
    func mediaMetaDataDidChange(_ aMedia: VLCMedia) {
        if(aMedia.metaData != nil ){
         updateMetaData(Media:aMedia)
        }
    }

    func updateMetaData(Media:VLCMedia){
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        let title = Media.metaData.title
        let artist = Media.metaData.artist
        let duration = Media.length.value
        let elapsedPlaybackTime = (mediaPlayer?.time.intValue ?? 0) / 1000


        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedPlaybackTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = mediaPlayer?.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.video.rawValue
        if let artworkUrl = Media.metaData.artworkURL, artworkDataTask?.originalRequest?.url != artworkUrl {
            artworkDataTask?.cancel()
            artworkDataTask = fetchArtwork(url: artworkUrl) { artwork in
                if let artwork = artwork {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                }
            }
        }
   
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

private func fetchArtwork(url: URL, completion: @escaping (MPMediaItemArtwork?) -> Void) -> URLSessionDataTask {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching artwork: \(error)")
            completion(nil)
            return
        }
        guard let data = data, response is HTTPURLResponse else {
            completion(nil)
            return
        }
        
        if let image = UIImage(data: data) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
            completion(artwork)
        } else {
            completion(nil)
        }
    }
    task.resume() // 确保任务开始执行
    return task
} 
