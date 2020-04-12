//
//  ViewController.swift
//  NFSpotifyAuth
//
//  Created by nferocious76 on 04/09/2020.
//  Copyright (c) 2020 nferocious76. All rights reserved.
//

import UIKit
import NFSpotifyAuth
import Alamofire

let SpotifyClientID = "c435e1b830ed4aee9260e8d0e319c7cd"
let SpotifyClientSecret = "cee1df07206048a7b665977dd74301c6"
let SpotifyCallbackURI = "http://api.domain/callback"
let SpotifyTokenRefreshServiceURL = "http://api.domain/callback/refresh"
let SpotifyTokenSwapServiceURL = "http://api.domain/callback/swap"

class ViewController: UIViewController, NFSpotifyLoginViewDelegate {

    @IBOutlet weak var connectButton: UIButton!
    private var loginView: NFSpotifyLoginView!
    private var miniPlayer: NFSpotifyMiniPlayerView!
    
    private var CountryCode: String = {
        (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String ?? "US"
    }()
    
    var token: NFSpotifyToken!
    var spotifyTracks: [NFSpotifyTrack]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .white
        connectButton.layer.cornerRadius = 4.0
        connectButton.clipsToBounds = true
        connectButton.backgroundColor = .gray
        
        NFSpotifyOAuth.shared.set(clientId: SpotifyClientID, clientSecret: SpotifyClientSecret, redirectURI: SpotifyCallbackURI)

        let rectFrame = CGRect(x: 30, y: 80, width: view.frame.width - 60, height: 400)
        loginView = NFSpotifyLoginView(frame: rectFrame, scopes: NFSpotifyAvailableScopes, delegate: self)
        view.addSubview(loginView)
        
        // mini player
        miniPlayer = NFSpotifyMiniPlayerView.instance(withDelegate: self)
        let playerFrame = CGRect(x: 0, y: view.frame.height - miniPlayer.frame.size.height, width: view.frame.size.width, height: miniPlayer.frame.size.height)
        view.addSubview(miniPlayer)
        miniPlayer.updateFrame(playerFrame)
    }

    @IBAction func connectButton(_ sender: UIButton) {
        
        loginView.show()
    }
}

// MARK: - NFSpotifyLoginViewDelegate

extension ViewController {
    
    func spotifyLoginViewDidShow(_ view: NFSpotifyLoginView) {
        connectButton.isHidden = true
        connectButton.isEnabled = false
        
    }
    
    func spotifyLoginViewDidClose(_ view: NFSpotifyLoginView) {
        connectButton.isHidden = false
        connectButton.isEnabled = true
        
    }
    
    func spotifyLoginView(_ view: NFSpotifyLoginView, didFailWithError error: Error?) {
        print("err: \(error)")
    }
    
    func spotifyLoginView(_ view: NFSpotifyLoginView, didLoginWithTokenObject tObject: NFSpotifyToken) {
        print("didLoginWithTokenObject: \(tObject)")
        
        token = tObject
        
        getTracks()
    }

}

// MARK: - Request

extension ViewController {
    
    func getProfile() {
        
        
        
    }
    
    func getTracks() {
        
        guard let accessToken = token.token else { return }
        
        let topTracks = NFSpotifyBaseURL + "/artists/6XyY86QOPPrYVGvF9ch6wz/top-tracks" // linkin park
        let headers = [
            HTTPHeader(name: "Accept", value: "application/json"),
            HTTPHeader(name: "Authorization", value: "Bearer \(accessToken)")
        ]
        
        let params = [
            "country": CountryCode
        ]
        
        AF
            .request(topTracks, method: .get, parameters: params, headers: HTTPHeaders(headers))
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .success(let value):
                    
                    let trackInfo = value as! [String: AnyObject]
                    
                    if trackInfo["error"] == nil {
                        if let tracks = trackInfo["tracks"] as? [[String: AnyObject]] {
                            print("tracks: ", tracks)
                            
                            var tempTracks: [NFSpotifyTrack] = []
                            
                            for track in tracks {
                                let spotifyTrack = NFSpotifyTrack(trackInfo: track)
                                tempTracks.append(spotifyTrack)
                            }
                            
                            if let firstTrack = tempTracks.first {
                                firstTrack.cacheSoundDataWithDelegate(self)
                            }
                            
                            self.spotifyTracks = tempTracks
                        }else{
                            print("track info: ", trackInfo)
                        }
                    }else{
                        print("error: ", trackInfo)
                    }
                    
                case .failure(let error):
                    print("error: ", error)
                }
        }
        
        
    }
}
