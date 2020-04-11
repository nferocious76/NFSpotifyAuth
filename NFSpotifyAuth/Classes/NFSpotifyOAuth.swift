//
//  NFSpotifyOAuth.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/9/20.
//

import Foundation
import Alamofire

public class NFSpotifyOAuth: NSObject {
    
    public static let shared = NFSpotifyOAuth()
    
    public var clientID: String!
    public var clientSecret: String!
    public var redirectURI: String!
    public var userDefaultKey: String!
    
    private
    override init() {
        super.init()
    }
    
    /*
    FLOW                    ACCESS USER RESOURCES   REQUIRES SECRET KEY (SERVER-SIDE)   ACCESS TOKEN REFRESH
    Authorization Code      Yes                     Yes                                 Yes
    Client Credentials      No                      Yes                                 No
    Implicit Grant          Yes                     No                                  No
    */
    
    public func set(clientId id: String, clientSecret secret: String, redirectURI uri: String, userDefaultKey key: String! = nil) {
        
        clientID = id
        clientSecret = secret
        redirectURI = uri
        userDefaultKey = key
    }
}

// MARK: - Requests

extension NFSpotifyOAuth {

    /*
     Client Credentials Flow
     
     The Client Credentials flow is used in server-to-server authentication. Only endpoints that do not access user information can be accessed. The advantage here in comparison with requests to the Web API made without an access token, is that a higher rate limit is applied.

     */
    // 1a. authorizes access returns access code
    public func getClientCredentialToken(completion: CompletionHandler = nil) {
        
        guard let clientID = clientID, let clientSecret = clientSecret else { return }
        
        let parameters: [String: AnyObject] = [
            "client_id": clientID as AnyObject,
            "client_secret": clientSecret as AnyObject,
            "grant_type": "client_credentials" as AnyObject
        ]
        
        AF
            .request(NFSpotifyAutorizationTokenExchangeURL, method: .post, parameters: parameters)
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    
                    let tokenInfo = value as! [String: AnyObject]
                    let tokenObject = NFSpotifyToken(tokenInfo: tokenInfo)
                    
                    let _ = archive(object: tokenObject, secure: true, key: NFSpotifyClientCredentialKey)
                    
                    completion?(tokenObject, nil)
                    
                case .failure(let error):
                    completion?(nil, processError(error: error))
                }
        }
    }
    
    /*
     Implicit Grant Flow
     
     Implicit grant flow is for clients that are implemented entirely using JavaScript and running in the resource owner’s browser. You do not need any server-side code to use it. Rate limits for requests are improved but there is no refresh token provided. This flow is described in RFC-6749.

     */
    // 1b. request application authorization
    public func authorizeApplication(state: String = "", show_dialog: Bool = false, completion: CompletionHandler = nil) {
        
        guard let clientID = clientID, let redirectURI = redirectURI else { return }
        
        let parameters: [String: AnyObject] = [
            "client_id": clientID as AnyObject,
            "response_type": "code" as AnyObject,
            "redirect_uri": redirectURI as AnyObject,
            "grant_type": "client_credentials" as AnyObject,
            "state": state as AnyObject,
            "scope": NFSpotifyAvailableScopes.joined(separator: " ") as AnyObject,
            "show_dialog": show_dialog as AnyObject
        ]
        
        AF
            .request(NFSpotifyAutorizationCodeURL, method: .post, parameters: parameters)
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    
                    let tokenInfo = value as! [String: AnyObject]
                    let tokenObject = NFSpotifyToken(tokenInfo: tokenInfo)
                    
                    let _ = archive(object: tokenObject, secure: true, key: NFSpotifyClientCredentialKey)
                    
                    completion?(tokenObject, nil)
                    
                case .failure(let error):
                    completion?(nil, processError(error: error))
                }
        }
    }

    /*
     Authorization Code Flow
     
     This flow is suitable for long-running applications in which the user grants permission only once. It provides an access token that can be refreshed. Since the token exchange involves sending your secret key, perform this on a secure location, like a backend service, and not from a client such as a browser or from a mobile app.

     */
    // 2. access and refresh tokens from access code
    public func accessTokenFromAccessCode(_ code: String, completion: CompletionHandler = nil) {
        
        guard let clientID = clientID, let clientSecret = clientSecret, let redirectURI = redirectURI else { return }
        
        let parameters: [String: AnyObject] = [
            "client_id": clientID as AnyObject,
            "client_secret": clientSecret as AnyObject,
            "grant_type": "authorization_code" as AnyObject,
            "redirect_uri": redirectURI as AnyObject,
            "code": code as AnyObject
        ]
        
        AF
            .request(NFSpotifyAutorizationTokenExchangeURL, method: .post, parameters: parameters)
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let value):

                    let tokenInfo = value as! [String: AnyObject]
                    let tokenObject = NFSpotifyToken(tokenInfo: tokenInfo)
                    
                    let _ = archive(object: tokenObject, secure: true, key: NFSpotifyClientCredentialKey)
                    
                    completion?(tokenObject, nil)
                    
                case .failure(let error):
                    completion?(nil, processError(error: error))
                }
        }
    }
    
    // 3. access token from refresh access token
    public func renewAccessToken(refreshToken token: String, completion: CompletionHandler = nil) {
        
        guard let clientID = clientID, let clientSecret = clientSecret else { return }
        
        let parameters: [String: AnyObject] = [
            "client_id": clientID as AnyObject,
            "client_secret": clientSecret as AnyObject,
            "grant_type": "refresh_token" as AnyObject,
            "refresh_token": token as AnyObject
        ]
        
        AF
            .request(NFSpotifyAutorizationTokenExchangeURL, method: .post, parameters: parameters)
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let value):

                    let tokenInfo = value as! [String: AnyObject]
                    let tokenObject = NFSpotifyToken(tokenInfo: tokenInfo)
                    
                    let _ = archive(object: tokenObject, secure: true, key: NFSpotifyClientCredentialKey)
                    
                    completion?(tokenObject, nil)
                    
                case .failure(let error):
                    completion?(nil, processError(error: error))
                }
        }
    }
}

// MARK: - Error

extension NFSpotifyOAuth {
    
    public class func createCustomError(withDomain domain: String = "com.NFSpotifyAuth.error", code: Int = 4776, userInfo: [String: Any]?) -> Error {
        
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
    
    public class func createCustomError(withDomain domain: String = "com.NFSpotifyAuth.error", code: Int = 4776, errorMessage msg: String) -> Error {
        
        return NSError(domain: domain, code: code, userInfo: ["message": msg])
    }
    
}
