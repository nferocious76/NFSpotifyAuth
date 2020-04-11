//
//  NFSpotifyToken.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/9/20.
//

import Foundation

public enum NFSpotifyTokenType: String {
    case `default`
    case client = "client_credentials"
    case access = "access_token"
    case auth = "authorization_code"
    case reresh = "refresh_token"
}

public class NFSpotifyToken: NSObject {
    
    // MARK: - Declarations
    
    public var token: String!
    public var type: NFSpotifyTokenType = .default
    public var scope: String!
    public var expiry: Double = 0.0
    public var refreshToken: String!
    
    public var expiryDate: Date!
    
    // MARK: - Initializers
    
    private
    override init() {
        super.init()
    }
    
    convenience public init(tokenInfo info: [String: AnyObject]) {
        self.init()
        
        updateToken(tokenInfo: info)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        guard let tkn = aDecoder.decodeObject(forKey: "token") as? String, let typ = aDecoder.decodeObject(forKey: "type") as? String else { return nil }
        self.init()
        
        token = tkn
        type = NFSpotifyTokenType(rawValue: typ)!
        scope = aDecoder.decodeObject(forKey: "scope") as? String
        refreshToken = aDecoder.decodeObject(forKey: "refreshToken") as? String
        expiryDate = aDecoder.decodeObject(forKey: "expiryDate") as? Date
        
        if let expry = aDecoder.decodeObject(forKey: "expiry"), let seconds = (expry as AnyObject).doubleValue {
            expiry = seconds
        }else{
            expiry = 0
        }
    }
    
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(token, forKey: "token")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(scope, forKey: "scope")
        aCoder.encode(refreshToken, forKey: "refreshToken")
        aCoder.encode(expiry, forKey: "expiry")
        aCoder.encode(expiryDate, forKey: "expiryDate")
    }
}

// MARK: - Controls

extension NFSpotifyToken {
    
    open func updateToken(tokenInfo info: [String: AnyObject]) {
        
        token = info["access_token"] as? String
        type = NFSpotifyTokenType(rawValue: info["token_type"] as! String)!
        scope = info["scope"] as? String
        refreshToken = info["refresh_token"] as? String
        
        if let seconds = info["expires_in"]?.doubleValue {
            expiry = seconds
            expiryDate = Date(timeIntervalSinceNow: seconds)
        }else{
            expiry = 0
            expiryDate = Date(timeIntervalSinceNow: 0)
        }
    }
}
