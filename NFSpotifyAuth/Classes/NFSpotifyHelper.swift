//
//  NFSpotifyError.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/11/20.
//

import Foundation

// MARK: - Error

public func processError(responseData response: [String: AnyObject] = [:], error: Error?) -> Error {
    
    if let errorInfo = response["error"] as? [String: AnyObject], let code = errorInfo["code"]?.integerValue, let message = response["message"] as? String {
        
        let error = NFSpotifyOAuth.createCustomError(code: code, errorMessage: message)
        return error
        
    }else if let errorInfo = response["error"] as? String, let errorDesc = response["error_description"] as? String {
        
        let error = NFSpotifyOAuth.createCustomError(userInfo: ["error": errorInfo, "description": errorDesc])
        return error
        
    }else if let error = error {
        return error
        
    }else{
        
        let error = NFSpotifyOAuth.createCustomError(errorMessage: "Unknown Error")
        return error
    }
}

// MARK: - Archiving

public func archive(object: Any, secure: Bool, key: String) -> Bool {
    
    if let archived = try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: secure) {
        
        UserDefaults.standard.set(archived, forKey: key)
        return UserDefaults.standard.synchronize()
    }
    
    return false
}

public func unarchive(key: String, forClass cls: [AnyClass]) -> Any? {
    
    if let archived = UserDefaults.standard.object(forKey: key) as? Data, let data = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: cls.self, from: archived) {
        
        return data
    }
    
    return nil
}
