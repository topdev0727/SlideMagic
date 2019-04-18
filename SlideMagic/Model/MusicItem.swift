//
//  MusicItem.swift
//  SlideMagic
//
//  Created by RX on 4/4/19.
//  Copyright © 2019 JZ. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

public class MusicItem {

    var musicTitle: String = "Unknown"
    var artist: String = "Unknown"
    var thumb: UIImage?
    var albumName: String = "Unknown"
    var durationInMin: String = "00:00"
    var durationInSec: Int = 0
    var fileURL: URL?
    
    init(withMPMediaItem item: MPMediaItem?) {
        guard let playerItem = item else { return }
        musicTitle = playerItem.title ?? "Unknown"
        thumb = playerItem.artwork?.image(at: CGSize(width: 100, height: 100))
        albumName = playerItem.albumTitle ?? "Unknown"
        artist = playerItem.artist ?? "Unknown"
        fileURL = playerItem.assetURL
        
        durationInSec = Int(playerItem.playbackDuration)
        durationInMin = "\(String(format: "%02d", durationInSec / 60)):\(String(format: "%02d", durationInSec % 60))"
    }

}

class MusicLibrary {
    
    // MARK: Status
    
    typealias LibraryStatus = MPMediaLibraryAuthorizationStatus
    
    /// Get current access status from iOS
    class var status: LibraryStatus {
        return MPMediaLibrary.authorizationStatus()
    }
    
    /// Ask access to iOS music library
    ///
    /// - Parameter handler: Block called after the user choses whether to authorize the app
    class func askAuthorization(handler: @escaping (LibraryStatus) -> Void) {
        
        MPMediaLibrary.requestAuthorization(handler)
    }
    
    private var musics: [MusicItem] = []
    
    var count: Int {
        get {
            return musics.count
        }
    }
    
    subscript(index: Int) -> MusicItem {
        get {
            return musics[index]
        }
    }
    
    init() {
        let librarySongs: Set<MPMediaItem> = Set(MPMediaQuery.songs().items ?? [])
        
        var songs = [MusicItem]()
        for songItem in librarySongs {
            songs.append(MusicItem(withMPMediaItem: songItem))
        }
        // Sort by artist
        songs.sort { song1, song2 in
            song1.artist.localizedCaseInsensitiveCompare(song2.artist) == .orderedAscending
        }
        musics = songs
    }
    
    private init(musics: [MusicItem]) {
        self.musics = musics
    }
}
