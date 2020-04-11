//
//  NFSpotifyImage.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/11/20.
//

import Foundation

public class NFSpotifyImage: NSObject, NSCoding {
    
    public var height: Float!
    public var width: Float!
    public var url: String!
    
    // MARK: - Initializers
    
    private
    override init() {
        super.init()
    }
    
    convenience public init(imageHeight: Float, imageWidth: Float, imageURL: String!) {
        self.init()
        
        height = imageHeight
        width = imageWidth
        url = imageURL
    }
    
    convenience public init(imageInfo: [String: AnyObject]) {
        
        let imageHeight = imageInfo["height"]?.floatValue ?? 0.0
        let imageWidth = imageInfo["width"]?.floatValue ?? 0.0
        let imageURL = imageInfo["url"] as? String ?? ""
        
        self.init(imageHeight: imageHeight, imageWidth: imageWidth, imageURL: imageURL)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        
        guard let height = (aDecoder.decodeObject(forKey: "height") as AnyObject).floatValue, let width = (aDecoder.decodeObject(forKey: "width") as AnyObject).floatValue, let url = aDecoder.decodeObject(forKey: "url") as? String else { return nil }
        
        self.init(imageHeight: height, imageWidth: width, imageURL: url)
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(height, forKey: "height")
        aCoder.encode(width, forKey: "width")
        aCoder.encode(url, forKey: "url")
    }
}
