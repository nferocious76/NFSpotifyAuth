# NFSpotifyAuth

[![CI Status](https://img.shields.io/travis/nferocious76/NFSpotifyAuth.svg?style=flat)](https://travis-ci.org/nferocious76/NFSpotifyAuth)
[![Version](https://img.shields.io/cocoapods/v/NFSpotifyAuth.svg?style=flat)](https://cocoapods.org/pods/NFSpotifyAuth)
[![License](https://img.shields.io/cocoapods/l/NFSpotifyAuth.svg?style=flat)](https://cocoapods.org/pods/NFSpotifyAuth)
[![Platform](https://img.shields.io/cocoapods/p/NFSpotifyAuth.svg?style=flat)](https://cocoapods.org/pods/NFSpotifyAuth)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Features

- [x] Spotify Authentication using WebOAuth

## Requirements

- iOS 13.0+
- Xcode 11.0+

## Installation

#### CocoaPods
NFSpotifyAuth is available through [CocoaPods](http://cocoapods.org/). To install `NFSpotifyAuth`, simply add the following line to your `Podfile`:

```ruby
pod 'NFSpotifyAuth'
```

#### Manually
1. Download and drop ```/Pod/Classes```folder in your project.  
2. Congratulations!  

## Usage

```swift

NFSpotifyOAuth.shared.set(clientId: SpotifyClientID, clientSecret: SpotifyClientSecret, redirectURI: SpotifyCallbackURI)

let rectFrame = CGRect(x: 30, y: 80, width: view.frame.width - 60, height: 400)
let loginView = NFSpotifyLoginView(frame: rectFrame, scopes: NFSpotifyAvailableScopes, delegate: self)
view.addSubview(loginView)
loginView.show()

// mini player
let miniPlayer = NFSpotifyMiniPlayerView.instance(withDelegate: self)
let playerFrame = CGRect(x: 0, y: view.frame.height - miniPlayer.frame.size.height, width: view.frame.size.width, height: miniPlayer.frame.size.height)
view.addSubview(miniPlayer)
miniPlayer.updateFrame(playerFrame)

// MARK: - NFSpotifyLoginViewDelegate

extension ViewController {
    
    func spotifyLoginViewDidShow(_ view: NFSpotifyLoginView) {
    
    }
    
    func spotifyLoginViewDidClose(_ view: NFSpotifyLoginView) {
    
    }
    
    func spotifyLoginView(_ view: NFSpotifyLoginView, didFailWithError error: Error?) {
        print("err: \(error)")
    }
    
    func spotifyLoginView(_ view: NFSpotifyLoginView, didLoginWithTokenObject tObject: NFSpotifyToken) {
        print("didLoginWithTokenObject: \(tObject)")
    }
}

```

## Author

Neil Francis Ramirez Hipona, nferocious76@gmail.com

## License

NFSpotifyAuth is available under the MIT license. See the [LICENSE](https://github.com/nferocious76/NFSpotifyAuth/blob/master/LICENSE) file for more info.
