//
//  NFSpotifyArtist.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/11/20.
//

import Foundation

public class NFSpotifyArtist: NSObject, NSCoding {
    
    public var id: String!
    public var name: String!
    public var uri: String!
    public var type: String!

    public var popularity: Int = 0
    public var genres: [String] = []
    
    public var iTunesArtistId: Int!
    public var iTunesArtistViewURL: String!
    
    public var images: [NFSpotifyImage] = [] // in reverse order $0 = large, $last = thumb
    
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
    
    convenience public init(artistID: String, artistName: String, artistURI: String! = nil, type typ: String! = "artist", imgs: [NFSpotifyImage] = []) {
        self.init()

        id = artistID
        name = artistName
        uri = artistURI
        type = typ
        
        images = imgs
    }
    
    convenience public init(artistInfo: [String: AnyObject]) {
        
        let artistID = artistInfo["id"] as? String ?? ""
        let artistName = artistInfo["name"] as? String ?? ""
        let artistURI = artistInfo["uri"] as? String ?? ""
        let type = artistInfo["type"] as? String ?? "artist"
        
        self.init(artistID: artistID, artistName: artistName, artistURI: artistURI, type: type)
        
        if let popularityRate = artistInfo["popularity"] as? Int {
            popularity = popularityRate
        }
        
        if let genres = artistInfo["genres"] as? [String] {
            setArtistGenres(genres: genres)
        }
        
        if let imagesInfo = artistInfo["images"] as? [[String: AnyObject]] {
            setArtistImages(imagesInfo)
        }
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        
        guard let artistID = aDecoder.decodeObject(forKey: "id") as? String, let name = aDecoder.decodeObject(forKey: "name") as? String else { return nil }

        let uri = aDecoder.decodeObject(forKey: "uri") as? String
        let type = aDecoder.decodeObject(forKey: "type") as? String

        self.init(artistID: artistID, artistName: name, artistURI: uri, type: type)
        
        popularity = (aDecoder.decodeObject(forKey: "popularity") as AnyObject).intValue ?? 0
        genres = aDecoder.decodeObject(forKey: "genres") as? [String] ?? []
        images = aDecoder.decodeObject(forKey: "images") as? [NFSpotifyImage] ?? []
    }
    
    public func encode(with aCoder: NSCoder) {

        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(uri, forKey: "uri")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(popularity, forKey: "popularity")
        aCoder.encode(genres, forKey: "genres")
        aCoder.encode(images, forKey: "images")
    }
    
    // MARK: - Controls
    
    func updateSelfWithInfo(_ info: [String: AnyObject]) {
        if let _ = info["error"] { return }
        
        id = info["id"] as? String ?? ""
        name = (info["name"] as? String) ?? ""
        uri = info["uri"] as? String ?? ""
        type = (info["type"] as? String) ?? "artist"

        if let popularityRate = info["popularity"] as? Int {
            popularity = popularityRate
        }
        
        if let genres = info["genres"] as? [String] {
            setArtistGenres(genres: genres)
        }
        
        if let imagesInfo = info["images"] as? [[String: AnyObject]] {
            setArtistImages(imagesInfo)
        }else{
            images = []
        }
    }
    
    // MARK: - Internal
    
    private func setArtistGenres(genres g: [String]) {
        
        genres = g
    }
    
    private func setArtistImages(_ imagesInfo: [[String: AnyObject]]) {
        images = []
        
        for imageInfo in imagesInfo {
            let image = NFSpotifyImage(imageInfo: imageInfo)
            images.append(image)
        }
    }
}
