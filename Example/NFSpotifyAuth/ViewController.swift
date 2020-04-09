//
//  ViewController.swift
//  NFSpotifyAuth
//
//  Created by nferocious76 on 04/09/2020.
//  Copyright (c) 2020 nferocious76. All rights reserved.
//

import UIKit
import NFSpotifyAuth

let SpotifyClientID = "c435e1b830ed4aee9260e8d0e319c7cd"
let SpotifyClientSecret = "cee1df07206048a7b665977dd74301c6"
let SpotifyCallbackURI = "http://api.domain/callback"
let SpotifyTokenRefreshServiceURL = "http://api.domain/callback/refresh"
let SpotifyTokenSwapServiceURL = "http://api.domain/callback/swap"

class ViewController: UIViewController, NFSpotifyLoginViewDelegate {

    private var loginView: NFSpotifyLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .gray
        
        NFSpotifyOAuth.shared.set(clientId: SpotifyClientID, clientSecret: SpotifyClientSecret, redirectURI: SpotifyCallbackURI)

        let rectFrame = CGRect(x: 30, y: 80, width: view.frame.width - 60, height: 400)
        loginView = NFSpotifyLoginView(frame: rectFrame, scopes: NFSpotifyAvailableScopes, delegate: self)
        view.addSubview(loginView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loginView.show()
    }

}

// MARK: - NFSpotifyLoginViewDelegate

extension ViewController {
    
    func spotifyLoginView(_ view: NFSpotifyLoginView, didFailWithError error: Error?) {
        
        print("err: \(error)")
    }
    
    func spotifyLoginView(_ view: NFSpotifyLoginView, didLoginWithTokenObject tObject: NFSpotifyToken) {
        
        print("didLoginWithTokenObject: \(tObject)")

    }

}
