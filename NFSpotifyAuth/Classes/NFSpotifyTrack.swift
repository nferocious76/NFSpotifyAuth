//
//  NFSpotifyTrack.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/11/20.
//

import Foundation

public protocol NFSpotifyTrackDelegate: NSObjectProtocol {
    
    func trackDidBeginCaching(_ track: NFSpotifyTrack)
    func trackDidFinishCaching(_ track: NFSpotifyTrack)
    func trackCachingFailed(_ track: NFSpotifyTrack, error: NSError?)
}

public enum NFSpotifyTrackSoundType: Int {
    case `default`
    case spotify
    case musicLibrary
}

public class NFSpotifyTrack: NSObject, NSCoding {
    
    public var id: String!
    public var name: String!
    public var popularity: Float!
    public var previewURL: String!
    public var durationMS: Double!
    public var trackNumber: Int!
    public var discNumber: Int!
    public var uri: String!
    public var type: String!
    
    public var album: NFSpotifyAlbum!
    public var artists: [NFSpotifyArtist] = []
    
    public var soundData: Data?
    public var isCachingSoundData: Bool = false
    
    public var iTunesArtistId: Int!
    public var iTunesArtistViewURL: String!
    
    // Music Library Settings
    
    public var soundType: NFSpotifyTrackSoundType = .spotify
    public var assetURL: URL! // used in soundType = .musicLibrary | MPMediaItem
    public var albumImage: UIImage! // used in soundType = .musicLibrary | MPMediaItem
    
    public weak var trackDelegate: NFSpotifyTrackDelegate!
    
    // MARK: - Initializers
    
    private
    override init() {
        super.init()
    }
    
    convenience public init(trackInfo: [String: AnyObject]) {
        self.init()
        
        id = trackInfo["id"] as? String
        name = trackInfo["name"] as? String
        popularity = trackInfo["popularity"]?.floatValue ?? -1.00000
        previewURL = (trackInfo["preview_url"] as? String) ?? ""
        discNumber = trackInfo["disc_number"]?.intValue ?? 0
        durationMS = trackInfo["duration_ms"]?.doubleValue ?? 0.0
        trackNumber = trackInfo["track_number"]?.intValue ?? 0
        uri = trackInfo["uri"] as? String
        type = (trackInfo["type"] as? String) ?? ""
        
        if let albumInfo = trackInfo["album"] as? [String: AnyObject] {
            album = NFSpotifyAlbum(albumInfo: albumInfo)
        }
        // assert(album != nil, "Track album was not set! Track ID: \(id)")
        
        if let artistInfos = trackInfo["artists"] as? [[String: AnyObject]] {
            artists = []
            
            for artistInfo in artistInfos {
                let artist = NFSpotifyArtist(artistInfo: artistInfo)
                artists.append(artist)
            }
        }
        // assert(artist != nil, "Track artist was not set! Track ID: \(id)")
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        guard
            let trackID = aDecoder.decodeObject(forKey: "id") as? String,
            let trackName = aDecoder.decodeObject(forKey: "name") as? String,
            let trackURI = aDecoder.decodeObject(forKey: "uri") as? String
            else { return nil }
        
        self.init()
        
        id = trackID
        name = trackName
        uri = trackURI

        popularity = (aDecoder.decodeObject(forKey: "popularity") as AnyObject).floatValue
        previewURL = aDecoder.decodeObject(forKey: "previewURL") as? String
        durationMS = (aDecoder.decodeObject(forKey: "durationMS") as AnyObject).doubleValue
        trackNumber = (aDecoder.decodeObject(forKey: "trackNumber") as AnyObject).intValue
        discNumber = (aDecoder.decodeObject(forKey: "discNumber") as AnyObject).intValue
        type = aDecoder.decodeObject(forKey: "type") as? String
        album = aDecoder.decodeObject(forKey: "album") as? NFSpotifyAlbum
        artists = aDecoder.decodeObject(forKey: "artists") as? [NFSpotifyArtist] ?? []

        soundData = nil
        isCachingSoundData = false
        
        trackDelegate = nil
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        
        aCoder.encode(popularity, forKey: "popularity")
        aCoder.encode(previewURL, forKey: "previewURL")
        aCoder.encode(durationMS, forKey: "durationMS")
        aCoder.encode(trackNumber, forKey: "trackNumber")
        aCoder.encode(discNumber, forKey: "discNumber")
        aCoder.encode(uri, forKey: "uri")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(album, forKey: "album")
        aCoder.encode(artists, forKey: "artists")
    }
}
