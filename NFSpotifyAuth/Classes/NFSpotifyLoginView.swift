//
//  NFSpotifyLoginView.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/9/20.
//

import Foundation
import UIKit
import WebKit

public protocol NFSpotifyLoginViewDelegate: NSObjectProtocol {
    
    // useful for updating UI
    func spotifyLoginViewDidShow(_ view: NFSpotifyLoginView)
    func spotifyLoginViewDidClose(_ view: NFSpotifyLoginView)
    
    // main observer protocol
    func spotifyLoginView(_ view: NFSpotifyLoginView, didLoginWithTokenObject tObject: NFSpotifyToken)
    func spotifyLoginView(_ view: NFSpotifyLoginView, didFailWithError error: Error?)
}

public class NFSpotifyLoginView: UIView {
    
    // MARK: - Declarations
    
    fileprivate var wkWebView: WKWebView!
    
    fileprivate var scopes: [String] = []
    
    public weak var delegate: NFSpotifyLoginViewDelegate!
    public var animationDuration: TimeInterval = 0.33
    public var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            wkWebView.layer.cornerRadius = cornerRadius
        }
    }
    
    // MARK: - Initializers
    
    private
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
    }

    required public init?(coder aDecoder: NSCoder) {
        self.init()
        
    }
    
    override public func encode(with aCoder: NSCoder) {
        
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

    }
    
    convenience public init(frame: CGRect, scopes s: [String] = NFSpotifyAvailableScopes, delegate d: NFSpotifyLoginViewDelegate) {
        self.init(frame: frame)
        
        scopes = s
        delegate = d
        
        isHidden = true
        transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        
        prepareWebLoginView(withFrame: frame)
        prepareCloseButton(withBaseFrame: frame)
    }
}

// MARK: - Helpers

extension NFSpotifyLoginView {
    
    fileprivate func prepareWebLoginView(withFrame frame: CGRect) {
        
        let jScript = "let meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        let wkUScript = WKUserScript(source: jScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let wkUController = WKUserContentController()
        wkUController.addUserScript(wkUScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = wkUController
        
        let webFrame = CGRect(x: 2, y: 2, width: frame.width - 4, height: frame.height - 4)
        wkWebView = WKWebView(frame: webFrame, configuration: configuration)
        addSubview(wkWebView)
        
        wkWebView.navigationDelegate = self
        wkWebView.layer.cornerRadius = cornerRadius
        pinViewToSelf(view: wkWebView)
        
        setStatusColor(color: NFSpotifyAuthDefault) // default
    }
    
    fileprivate func prepareCloseButton(withBaseFrame frame: CGRect) {
        
        let buttonFrame = CGRect(x: frame.width - 34, y: 2, width: 32, height: 32)
        let closeButton = UIButton(frame: buttonFrame)
        
        let bundle = Bundle(for: NFSpotifyLoginView.self)
        let image = UIImage(named: "close", in: bundle, with: .none) // #imageLiteral(resourceName: "close")
        closeButton.setImage(image, for: .normal)
        
        addSubview(closeButton)
        
        let top = NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: closeButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        
        addConstraints([top, right])
        
        let width = NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        let height = NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        
        closeButton.addConstraints([width, height])
        
        closeButton.clipsToBounds = true
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(self.closeButtonAction(_:)), for: .touchUpInside)
    }
    
    fileprivate func pinViewToSelf(view: UIView) {
        
        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10)
        let left = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: -10)
        let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -10)
        let right = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 10)
        
        addConstraints([top, left, bottom, right])
    }
    
    fileprivate func loadURL(url: URL) {
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        wkWebView.load(request)
    }
    
    /** Construct 'Access Code' request link */
    fileprivate func accessCodeRequestOAuthURL(forRedirectURI redirectURI: String, state: String! = nil, show_dialog: Bool = false) -> URL! {
        
        let shared = NFSpotifyOAuth.shared
        guard let clientID = shared.clientID, let redirectURI = shared.redirectURI else { return nil }
        
        let uri = redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let urlClientId = "?client_id=\(clientID)"
        let urlResponseType = "&response_type=code"
        let urlRedirectURI = "&redirect_uri=\(uri)"
        
        var urlScopes = ""
        var stateKey = ""
        
        if !scopes.isEmpty {
            for scope in scopes {
                if urlScopes.isEmpty {
                    urlScopes = "&scope=\(scope)"
                }else{
                    urlScopes += "%20\(scope)"
                }
            }
        }else{
            urlScopes = "&scope=streaming%20user-read-email%20playlist-read-private%20user-read-private"
        }
        
        if let state = state {
            stateKey = "state=\(state)"
        }
        
        let dialog = show_dialog ? "&show_dialog=true" : ""
        let accessCodeURL = "\(NFSpotifyAutorizationCodeURL)" + urlClientId + urlResponseType + urlRedirectURI + urlScopes + stateKey + dialog
        
        // 1.
        guard let authURL = URL(string: accessCodeURL) else { return nil }
        return authURL
    }
}

// MARK: - Animation

extension NFSpotifyLoginView {

    public func show(isAnimated animated: Bool = true) {
        
        guard let redirectURI = NFSpotifyOAuth.shared.redirectURI else { return }
        guard let accessCodeAuthURL = accessCodeRequestOAuthURL(forRedirectURI: redirectURI) else { return }
        
        loadURL(url: accessCodeAuthURL)
        
        DispatchQueue.main.async {
            self.isHidden = false
            
            if animated {
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                UIView.animate(withDuration: self.animationDuration) {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.delegate.spotifyLoginViewDidShow(self)
                }
            }else{
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.delegate.spotifyLoginViewDidShow(self)
            }
        }
    }
    
    public func hide(isAnimted animated: Bool = true) {
        
        self.wkWebView.stopLoading()
        
        DispatchQueue.main.async {
            if animated {
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                }) { (isFinished) in
                    self.isHidden = true
                    self.delegate.spotifyLoginViewDidClose(self)
                }
            }else{
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                self.isHidden = true
                self.delegate.spotifyLoginViewDidClose(self)
            }
        }
    }
}

// MARK: - Controls

extension NFSpotifyLoginView {
    
    internal func setStatusColor(color: UIColor) {
        
        backgroundColor = color
    }
    
    @objc func closeButtonAction(_ sender: UIButton) {
        
        hide()
    }
}
