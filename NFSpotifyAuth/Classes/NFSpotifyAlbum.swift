//
//  NFSpotifyAlbum.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/11/20.
//

import Foundation

public class NFSpotifyAlbum: NSObject, NSCoding {
    
    public var id: String!
    public var name: String!
    public var uri: String!
    public var type: String!
    public var albumType: String!
    
    public var images: [NFSpotifyImage] = [] // in reverse order $0 = large, $last = thumb
    public var tracks: [NFSpotifyTrack] = []
    
    public var availableMarkets: [String] = []
    
    public var iTunesAlbumId: Int!
    public var iTunesAlbumURL: String!
    
    public weak var artist: NFSpotifyArtist!

    public var thumbImageURL: String! {
        if let image = images.last {
            return image.url
        }
        
        return nil
    }
    
    public var largeImageURL: String! {
        if let image = images.first {
            return image.url
        }
        
        return nil
    }
    
    // MARK: - Initializers
    
    private
    override init() {
        super.init()
    }
    
    convenience public init(albumID: String, albumName: String, albumURI: String, type t: String! = nil, albumType at: String! = nil) {
        self.init()
        
        id = albumID
        name = albumName
        uri = albumURI
        type = t
        albumType = at
    }
    
    convenience public init(albumInfo: [String: AnyObject]) {
        
        let albumID = albumInfo["id"] as! String
        let albumName = (albumInfo["name"] as? String) ?? ""
        let albumURI = albumInfo["uri"] as! String
        let type = (albumInfo["type"] as? String) ?? nil
        let albumType = (albumInfo["album_type"] as? String) ?? nil
        
        self.init(albumID: albumID, albumName: albumName, albumURI: albumURI, type: type, albumType: albumType)
        
        if let imagesInfo = albumInfo["images"] as? [[String: AnyObject]] {
            for imageInfo in imagesInfo {
                let albumImage = NFSpotifyImage(imageInfo: imageInfo)
                images.append(albumImage)
            }
        }
        
        if let markets = albumInfo["available_markets"] as? [String] {
            availableMarkets = markets
        }
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        
        guard
            let albumID = aDecoder.decodeObject(forKey: "id") as? String,
            let albumName = aDecoder.decodeObject(forKey: "name") as? String,
            let albumURI = aDecoder.decodeObject(forKey: "uri") as? String
            else { return nil }
        
        self.init(albumID: albumID, albumName: albumName, albumURI: albumURI)

        type = aDecoder.decodeObject(forKey: "type") as? String
        albumType = aDecoder.decodeObject(forKey: "albumType") as? String
        
        artist = aDecoder.decodeObject(forKey: "artist") as? NFSpotifyArtist
        
        images = aDecoder.decodeObject(forKey: "images") as? [NFSpotifyImage] ?? []
        tracks = aDecoder.decodeObject(forKey: "tracks") as? [NFSpotifyTrack] ?? []
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(uri, forKey: "uri")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(albumType, forKey: "albumType")

        aCoder.encode(artist, forKey: "artist")
        
        aCoder.encode(images, forKey: "images")
        aCoder.encode(tracks, forKey: "tracks")
    }
}
