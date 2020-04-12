//
//  NFSpotifyMediaPlayer.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/12/20.
//

import Foundation
import AVFoundation

public protocol NFSpotifyMediaPlayerDelegate: NSObjectProtocol {
 
    func mediaPlayer(_ player: NFSpotifyMediaPlayer, didUpdateStatus status: NFSpotifyMediaPlayerStatus, forTrack track: NFSpotifyTrack!)
    func mediaPlayer(_ player: NFSpotifyMediaPlayer, didUpdatePlayback playback: NFSpotifyPlayback)
}

public struct NFSpotifyPlayback {
    var track: NFSpotifyTrack!
    var position: TimeInterval
    var duration: TimeInterval
    var progress: Float
}

public class NFSpotifyMediaPlayer: NSObject {
    
    internal var mediaPlayer: AVAudioPlayer!
    internal var progressTimer: Timer!

    public weak var delegate: NFSpotifyMediaPlayerDelegate!
    
    // MARK: - Getter
    
    public var isPlaying: Bool {
        if let player = mediaPlayer {
            return player.isPlaying
        }
        
        return false
    }
    
    public var playbackPosition: TimeInterval {
        if let player = mediaPlayer {
            return player.currentTime
        }
        
        return 0.0
    }
    
    public var playbackDuration: TimeInterval {
        if let player = mediaPlayer {
            return player.duration
        }
        
        return 30.0
    }
    
    public var playbackProgress: Float {
        if let player = mediaPlayer {
            return Float(player.currentTime / player.duration)
        }

        return 0
    }
    
    public var playbackDurationDescription: String {
        if let player = mediaPlayer {
            return durationDescription(player.duration)
        }
        
        return "0:30"
    }
    
    public var playbackPositionDescription: String {
        if let player = mediaPlayer {
            return durationDescription(player.currentTime)
        }
        
        return "0:00"
    }
    
    public var track: NFSpotifyTrack! {
        didSet {
            // start download
        }
    }
    
    public var status: NFSpotifyMediaPlayerStatus = .default {
        didSet {
            delegate.mediaPlayer(self, didUpdateStatus: status, forTrack: track)
        }
    }
    
    // MARK: - Initializer
    
    private
    override init() {
        super.init()
        
        prepareAudioSession()
    }
    
    convenience public init(withDelegate delegate: NFSpotifyMediaPlayerDelegate) {
        self.init()
        
        self.delegate = delegate
    }
}

// MARK: Internal Media Player Controls

extension NFSpotifyMediaPlayer {
    
    internal func startProgressTimer() {
        stopProgressTimer()
        
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.progressTimerUpdate), userInfo: nil, repeats: true)
    }
    
    internal func stopProgressTimer() {
        if let timer = progressTimer {
            timer.invalidate()
            progressTimer = nil
        }
    }
    
    @objc func progressTimerUpdate() {
        
        let playback = NFSpotifyPlayback(track: track, position: playbackPosition, duration: playbackDuration, progress: playbackProgress)
        delegate.mediaPlayer(self, didUpdatePlayback: playback)
    }
    
    internal func durationDescription(_ duration: TimeInterval) -> String {

        let maxValue = round(duration)
        
        if maxValue > 59 {
            let min = Int(maxValue / 60)
            let seconds = maxValue - Double(min * 60)
            
            let readableFormat = seconds > 9 ? String(format: "\(min):%.0f", seconds) : String(format: "\(min):0%.0f", seconds)
            
            return readableFormat
        }else{
            let readableFormat = maxValue > 9 ? String(format: "0:%.0f", maxValue) : String(format: "0:0%.0f", maxValue)
            
            return readableFormat
        }
    }
    
    internal func prepareAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            
            let category = AVAudioSession.Category.playback.rawValue
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: category))
        }catch{
            print("AVAudioSession Error %@", error)
        }
    }
    
    internal func prepareMediaPlayer(track: NFSpotifyTrack) -> AVAudioPlayer? {
        
        if track.soundType == .musicLibrary, let assetURL = track.assetURL {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: assetURL)
                audioPlayer.delegate = self
                
                return audioPlayer
            }catch{
                print(error)
            }
        }else if let soundData = track.soundData {
            do {
                let audioPlayer = try AVAudioPlayer(data: soundData)
                audioPlayer.delegate = self
                
                return audioPlayer
            }catch{
                print(error)
            }
        }else{
            print("'prepareMediaPlayer' Error")
        }
        
        return nil
    }
}

// MARK: - AVAudioPlayerDelegate

extension NFSpotifyMediaPlayer: AVAudioPlayerDelegate {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        status = .stopped
        
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        status = .stopped
        
    }
}

// MARK: - NFSpotifyTrackDelegate

extension NFSpotifyMediaPlayer: NFSpotifyTrackDelegate {
    
    public func trackDidBeginCaching(_ track: NFSpotifyTrack) {
        status = .caching
    }
    
    public func trackDidFinishCaching(_ track: NFSpotifyTrack) {
        
        playTrack()
    }
    
    public func trackDidFailCaching(_ track: NFSpotifyTrack, error: Error?) {
        status = .stopped
    }
}

// MARK: - Media Player Controls

extension NFSpotifyMediaPlayer {
    
    public func playTrack() {
        guard let track = track else { return }
        
        if track.soundData != nil || track.soundType == .musicLibrary {
            if let player = prepareMediaPlayer(track: track) {
                player.volume = 1.0
                player.play()
                status = .playing
                
                mediaPlayer = player
            }
        }else{
            status = .caching
            track.cacheSoundDataWithDelegate(self)
        }
    }
}
