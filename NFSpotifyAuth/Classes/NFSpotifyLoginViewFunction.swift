//
//  NFSpotifyLoginViewFunction.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/12/20.
//

import Foundation
import WebKit

// MARK: - WKNavigationDelegate

extension NFSpotifyLoginView: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        print("SpotifyAuthLoginView didCommit navigation: \(webView.url?.absoluteString ?? "")")
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("SpotifyAuthLoginView didFinish navigation: \(webView.url?.absoluteString ?? "")")
        
        guard let url = webView.url else {
            let error = NFSpotifyOAuth.createCustomError(errorMessage: "No valid address")
            
            setStatusColor(color: NFSpotifyAuthWarning)
            return delegate.spotifyLoginView(self, didFailWithError: error)
        }
        
        guard let queryItems = url.queryItems else {
            let error = NFSpotifyOAuth.createCustomError(errorMessage: "No valid access code")
            
            setStatusColor(color: NFSpotifyAuthWarning)
            return self.delegate.spotifyLoginView(self, didFailWithError: error)
        }
        
        guard let accessCode = queryItems["code"] else {
            let error = NFSpotifyOAuth.createCustomError(errorMessage: "No valid access code")
            
            setStatusColor(color: NFSpotifyAuthWarning)
            return self.delegate.spotifyLoginView(self, didFailWithError: error)
        }
        
        // 2.
        NFSpotifyOAuth.shared.accessTokenFromAccessCode(accessCode) { (tokenObject, error) in
            
            if let tokenObject = tokenObject, let _ = tokenObject.token {
                self.setStatusColor(color: NFSpotifyAuthSuccess)
                self.delegate.spotifyLoginView(self, didLoginWithTokenObject: tokenObject)
                self.hide()
            }else if let error = error {
                self.setStatusColor(color: NFSpotifyAuthError)
                self.delegate.spotifyLoginView(self, didFailWithError: error)
            }else{
                let error = NFSpotifyOAuth.createCustomError(errorMessage: "Unkown error")
                self.setStatusColor(color: NFSpotifyAuthError)
                self.delegate.spotifyLoginView(self, didFailWithError: error)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        print("SpotifyAuthLoginView didFail navigation: \(webView.url?.absoluteString ?? "") -- error: \(error)")
        
        delegate.spotifyLoginView(self, didFailWithError: error)
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        
        print("SpotifyAuthLoginView webViewWebContentProcessDidTerminate: \(webView.url?.absoluteString ?? "")")
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print("SpotifyAuthLoginView didReceiveServerRedirectForProvisionalNavigation navigation: \(webView.url?.absoluteString ?? "")")
        
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
        print("SpotifyAuthLoginView didReceiveServerRedirectForProvisionalNavigation navigation: \(webView.url?.absoluteString ?? "")")
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        print("SpotifyAuthLoginView didFailProvisionalNavigation: \(webView.url?.absoluteString ?? ""), error: \(error)")
    }
}
