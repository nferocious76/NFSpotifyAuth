//
//  NFSpotifyTrackMedia.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/11/20.
//

import Foundation
import Alamofire

// MARK: - Helpers

extension NFSpotifyTrack {
    
    public func cacheSoundDataWithDelegate(_ delegate: NFSpotifyTrackDelegate) {
        
        // this will replace the reference of the previous observer
        // the newly set observer will receive the updates
        trackDelegate = delegate
        
        if isCachingSoundData { return }
        
        isCachingSoundData = true
        trackDelegate.trackDidBeginCaching(self)
        
        if previewURL.isEmpty {
            let description = "No valid previewURL to download sound data for track name: \(name ?? "") --- url: \(previewURL ?? "")"
            print(description)
            
            self.isCachingSoundData = false
            
            let error = NFSpotifyOAuth.createCustomError(withDomain: "com.NFSpotifyAuth.download.error", userInfo: ["message": "This song requires Spotify Premium", "description": description])
            self.trackDelegate.trackDidFailCaching(self, error: error)
        }else{
            
            downloadTrackSoundDataFromURLString(previewURL) { (responseData, error) in
                self.isCachingSoundData = false
                
                if let responseData = responseData {
                    self.soundData = responseData
                    self.trackDelegate.trackDidFinishCaching(self)
                }else{
                    let description = "Failed to download sound data for track name: \(self.name ?? "") --- url: \(self.previewURL ?? "") --- error: \(error?.localizedDescription ?? "Unknown Error")"
                    print(description)
                    
                    self.trackDelegate.trackDidFailCaching(self, error: processError(error: error))
                }
            }
        }
    }
    
}

extension NFSpotifyTrack {
    
    fileprivate func downloadTrackSoundDataFromURLString(_ trackURL: String, userAgent: String = "", completion: CompletionDataHandler = nil) {
        
        var headers: HTTPHeaders? = nil
        if userAgent.isEmpty {
            let tmpHeaders = [
                HTTPHeader(name: "User-Agent", value: userAgent)
            ]
            
            headers = HTTPHeaders(tmpHeaders)
        }
        
        AF
            .request(trackURL, method: .get, headers: headers)
            .responseJSON { (response) in
                
                if let soundData = response.data, soundData.count > 2 {
                    completion?(soundData, nil)
                }else{
                    if userAgent.isEmpty { // Try iTunes
                        self.downloadTrackSoundDataFromURLString(trackURL, userAgent: iTunesUserAgent, completion: completion)
                    }else{
                        let error = NFSpotifyOAuth.createCustomError(withDomain: "com.NFSpotifyAuth.download.error", errorMessage: "unable to download track.")
                        completion?(nil, error)
                    }
                }
        }
    }
}
