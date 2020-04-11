//
//  NFSpotifyConstant.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/9/20.
//

import Foundation

/// Spotify API Base URL
public let NFSpotifyBaseURL = "https://api.spotify.com/v1"

/// Authorization for access code for token exchange
public let NFSpotifyAutorizationCodeURL: String = "https://accounts.spotify.com/authorize"

/// Exchange code for token
public let NFSpotifyAutorizationTokenExchangeURL: String = "https://accounts.spotify.com/api/token"

/// Authorization Scopes
public let NFSpotifyAvailableScopes: [String] = [

    // Image
    "ugc-image-upload",
    
    // Spotify Connect
    "user-read-playback-state",
    "user-modify-playback-state",
    "user-read-currently-playing",
    
    // Playback
    "streaming",
    "app-remote-control",
    
    // Users
    "user-read-email",
    "user-read-private",
    
    // Playlists
    "playlist-read-collaborative",
    "playlist-modify-public",
    "playlist-read-private",
    "playlist-modify-private",
    
    // Library
    "user-library-modify",
    "user-library-read",
    
    // Listening History
    "user-top-read",
    "user-read-playback-position",
    "user-read-recently-played",
    
    // Follow
    "user-follow-read",
    "user-follow-modify"
]

// MARK: - Color Legends

/// Default status
public let NFSpotifyAuthDefault = UIColor.gray

/// Warning status
public let NFSpotifyAuthWarning = UIColor.orange

/// Error status
public let NFSpotifyAuthError = UIColor.red

/// Success status
public let NFSpotifyAuthSuccess = UIColor.green

/// Completion handler alias
public typealias CompletionHandler = ((_ tokenObject: NFSpotifyToken?, _ error: Error?) -> Void)?


/// Keys
public let NFSpotifyClientCredentialKey = "NFSpotifyAccessTokenClientCredentialsKey"
public let NFSpotifyAccessCodeLoginKey = "NFSpotifyAccessCodeKey"
public let NFSpotifyAccessTokenLoginCredentialsKey = "NFSpotifyAccessTokenLoginCredentialsKey"
public let NFSpotifyAccessTokenLoginRefreshKey = "NFSpotifyAccessTokenRefreshKey"
