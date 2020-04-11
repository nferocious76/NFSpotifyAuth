//
//  NFSpotifyProfile.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/9/20.
//

import Foundation
import Alamofire

open class NFSpotifyProfile: NSObject, NSCoding {
    
    static public let me = NFSpotifyProfile()
    
    // MARK: - Declarations
    
    public var id: String!
    public var birthdate: String!
    public var country: String!
    public var display_name: String!
    public var email: String!
    public var href: String!
    public var followers: Int = 0
    public var image_url: String!
    public var product: String!
    public var type: String!
    public var uri: String!
    
    public var profileCacheKey: String!
    
    // MARK: - Initializers
    
    private
    override init() {
        super.init()
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        guard let i = aDecoder.decodeObject(forKey: "id") as? String else { return nil }
        
        let me = NFSpotifyProfile.me
        
        me.id = i
        
        me.birthdate = aDecoder.decodeObject(forKey: "birthdate") as? String
        me.country = aDecoder.decodeObject(forKey: "country") as? String
        me.display_name = aDecoder.decodeObject(forKey: "display_name") as? String
        me.email = aDecoder.decodeObject(forKey: "email") as? String
        me.href = aDecoder.decodeObject(forKey: "href") as? String
        
        if let f = aDecoder.decodeObject(forKey: "followers"), let count = (f as AnyObject).integerValue {
            me.followers = count
        }else{
            me.followers = 0
        }
        
        me.image_url = aDecoder.decodeObject(forKey: "image_url") as? String
        me.product = aDecoder.decodeObject(forKey: "product") as? String
        me.type = aDecoder.decodeObject(forKey: "type") as? String
        me.uri = aDecoder.decodeObject(forKey: "uri") as? String
        
        return nil
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(id, forKey: "id")
        aCoder.encode(birthdate, forKey: "birthdate")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(display_name, forKey: "display_name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(href, forKey: "href")
        aCoder.encode(followers, forKey: "followers")
        aCoder.encode(image_url, forKey: "image_url")
        aCoder.encode(product, forKey: "product")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(uri, forKey: "uri")
    }
}

// MARK: - Controls

extension NFSpotifyProfile {
    
    public func updateProfile(info profileInfo: [String: AnyObject]) {
        
        id = profileInfo["id"] as? String
        birthdate = profileInfo["birthdate"] as? String
        country = profileInfo["country"] as? String
        display_name = profileInfo["display_name"] as? String
        email = profileInfo["email"] as? String
        href = profileInfo["href"] as? String
        
        if let followersInfo = profileInfo["followers"] as? [String: AnyObject], let followerCount = followersInfo["total"]?.integerValue {
            followers = followerCount
        }
        
        if let images = profileInfo["images"] as? [[String: AnyObject]], let image = images.first, let imageURL = image["url"] as? String {
            image_url = imageURL
        }
        
        product = profileInfo["product"] as? String
        type = profileInfo["type"] as? String
        uri = profileInfo["uri"] as? String
        
        if let profileCacheKey = self.profileCacheKey {
            guard let archivedProfile = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true) else { return }
            
            UserDefaults.standard.set(archivedProfile, forKey: profileCacheKey)
            UserDefaults.standard.synchronize()
        }
    }
}

// MARK: - File Controls

extension NFSpotifyProfile {
    
    public func loadFromDisk() -> Bool {
        
        if let userData = UserDefaults.standard.object(forKey: "SpotifyProfileCacheKey") as? Data, let _ = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NFSpotifyProfile.self, from: userData) {
            
            return true
        }
        
        return false
    }
    
    public func saveToDisk() -> Bool {
        
        guard let archivedProfile = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true) else { return false }
        
        UserDefaults.standard.set(archivedProfile, forKey: profileCacheKey)
        return UserDefaults.standard.synchronize()
    }
}

extension NFSpotifyProfile {
    
    public func getProfile(withAccessToken token: String, completion: ((_ profileInfo: [String: AnyObject]?, _ error: Error?) -> Void)?) {

        let spotifyHeaders = HTTPHeaders([
            HTTPHeader(name: "Accept", value: "application/json"),
            HTTPHeader(name: "Authorization", value: "Bearer \(token)")
        ])
        
        let profileURL = NFSpotifyBaseURL + "/me"
        
        AF
            .request(profileURL, method: .post, headers: spotifyHeaders)
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    print("\nSpotify profile info: \(value)")
                    
                    let profileInfo = value as! [String: AnyObject]
                    self.updateProfile(info: profileInfo)
                    completion?(profileInfo, nil)
                    
                case .failure(let error):
                    completion?(nil, error)
                }
        }
    }
}
