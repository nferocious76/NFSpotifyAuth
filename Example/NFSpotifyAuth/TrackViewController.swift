//
//  TrackViewController.swift
//  NFSpotifyAuth_Example
//
//  Created by Neil Francis Hipona on 4/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import NFSpotifyAuth

// MARK: - NFSpotifyTrackDelegate
extension ViewController: NFSpotifyTrackDelegate {
    
    func trackDidBeginCaching(_ track: NFSpotifyTrack) {
        print("trackDidBeginCaching track name: ", track.name ?? "")
        
    }
    
    func trackDidFinishCaching(_ track: NFSpotifyTrack) {
        print("trackDidFinishCaching track name: ", track.name ?? "")
        
    }
    
    func trackDidFailCaching(_ track: NFSpotifyTrack, error: Error?) {
        print("trackDidFailCaching track name: ", track.name ?? "")
        
    }
    
}
