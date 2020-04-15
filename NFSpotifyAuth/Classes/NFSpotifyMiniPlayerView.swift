//
//  NFSpotifyMiniPlayerView.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/12/20.
//

import Foundation
import AVFoundation
import NFImageView

public protocol NFSpotifyMiniPlayerViewDelegate: NSObjectProtocol {
    
    func musicMiniPlayerViewDidShow(_ view: NFSpotifyMiniPlayerView)
    func musicMiniPlayerViewDidClose(_ view: NFSpotifyMiniPlayerView)
    
    func musicMiniPlayerViewDidTapToggle(_ view: NFSpotifyMiniPlayerView)
    func musicMiniPlayerViewDidTapPlay(_ view: NFSpotifyMiniPlayerView)
}

public class NFSpotifyMiniPlayerView: UIView {
    
    @IBOutlet weak internal var progressView: UIProgressView! // Playback progress bar
    @IBOutlet weak internal var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet weak internal var titleLbl: UILabel!
    @IBOutlet weak internal var detailLbl: UILabel!
    
    @IBOutlet weak internal var trackImage: NFImageView!
    @IBOutlet weak internal var sourceBadge: UIImageView!
    
    @IBOutlet weak internal var playPauseButton: UIButton!
    @IBOutlet weak internal var toggleButton: UIButton! // view toggle handler
    
    // MARK: - Declarations
    
    public weak var delegate: NFSpotifyMiniPlayerViewDelegate!
    
    public var mediaPlayer: NFSpotifyMediaPlayer!
    public var animationDuration: TimeInterval = 0.33
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    public var progressTintColor: UIColor = .blue {
        didSet {
            progressView.progressTintColor = progressTintColor
        }
    }

    public var trackTintColor: UIColor = UIColor(red: 146, green: 146, blue: 146, alpha: 1) {
        didSet {
            progressView.trackTintColor = trackTintColor
        }
    }
    
    public var titleLblFont: UIFont = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold) {
        didSet {
            titleLbl.font = titleLblFont
        }
    }
    
    public var detailLblFont: UIFont = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular) {
        didSet {
            detailLbl.font = detailLblFont
        }
    }
    
    public var titleLblTextColor: UIColor = .black {
        didSet {
            titleLbl.textColor = titleLblTextColor
        }
    }
    
    public var detailLblTextColor: UIColor = .lightGray {
        didSet {
            detailLbl.textColor = detailLblTextColor
        }
    }
    
    public var track: NFSpotifyTrack! {
        didSet {
            mediaPlayer.track = track
            updateTrack(track)
        }
    }
    
    public var status: NFSpotifyMediaPlayerStatus = .default {
        didSet {
            updateStatus(status)
        }
    }

    public class func instance(withDelegate delegate: NFSpotifyMiniPlayerViewDelegate) -> NFSpotifyMiniPlayerView {
        
        let bundle = Bundle(for: NFSpotifyMiniPlayerView.self)
        let nib = UINib(nibName: "NFSpotifyMiniPlayerView", bundle: bundle)
        let miniPlayer = nib.instantiate(withOwner: nil, options: nil).first as! NFSpotifyMiniPlayerView
        miniPlayer.delegate = delegate
        
        return miniPlayer
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
     
        mediaPlayer = NFSpotifyMediaPlayer(withDelegate: self)
        prepareMiniPlayer()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let topLine = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.size.width, height: 0.5))
        NFSpotifyMiniPlayerHairline.setStroke()
        topLine.lineWidth = 0.5
        topLine.stroke()
        
        let bottomLine = UIBezierPath(rect: CGRect(x: 0, y: frame.size.height - 0.5, width: frame.size.width, height: 0.5))
        NFSpotifyMiniPlayerHairline.setStroke()
        bottomLine.lineWidth = 0.5
        bottomLine.stroke()
    }
    
    private func prepareMiniPlayer() {
        
        clipsToBounds = true
        let bundle = Bundle(for: NFSpotifyMiniPlayerView.self)
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        toggleButton.setBackgroundImage(generateImageWithColor(color), for: .highlighted) // add responsive tap effect on toggle
        toggleButton.backgroundColor = .clear
        
        let playImage = UIImage(named: "PlayButton", in: bundle, compatibleWith: .none)
        playPauseButton.setImage(playImage, for: .normal) // currently at default state
        
        let pauseImage = UIImage(named: "PauseButton", in: bundle, compatibleWith: .none)
        playPauseButton.setImage(pauseImage, for: .selected) // currently at playing state
        
        progressView.progressTintColor = progressTintColor
        progressView.trackTintColor = trackTintColor
        progressView.progress = 0.0
        
        trackImage.clipsToBounds = true
        trackImage.layer.cornerRadius = 1.0
        trackImage.contentMode = .scaleAspectFill
        trackImage.loadingType = .progress
        trackImage.loadingEnabled = true
        
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        // Mini Player Labels
        titleLbl.font = titleLblFont
        titleLbl.textColor = titleLblTextColor
        
        detailLbl.font = detailLblFont
        detailLbl.textColor = detailLblTextColor
    }
    
    // MARK: - Actions
    
    @IBAction private func playPauseButton(_ sender: UIButton) {
        
        self.delegate.musicMiniPlayerViewDidTapPlay(self)
        
        mediaPlayer.isPlaying ? mediaPlayer.pauseTrack() : mediaPlayer.playTrack()
    }
    
    @IBAction private func toggleButton(_ sender: UIButton) {

        self.delegate.musicMiniPlayerViewDidTapToggle(self)
    }
}

// MARK: - NFSpotifyMediaPlayerDelegate

extension NFSpotifyMiniPlayerView: NFSpotifyMediaPlayerDelegate {
    
    public func mediaPlayer(_ player: NFSpotifyMediaPlayer, didUpdateStatus status: NFSpotifyMediaPlayerStatus, forTrack track: NFSpotifyTrack!) {
        
        self.status = status
        updateTrack(track)
    }
    
    public func mediaPlayer(_ player: NFSpotifyMediaPlayer, didUpdatePlayback playback: NFSpotifyPlayback) {
        
        progressView.progress = playback.progress
    }
}

// MARK: - Internal Controls

extension NFSpotifyMiniPlayerView {
        
    private func generateImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func loadSpotifyImage(fromURL albumCoverArtURL: String?) {
        
        let bundle = Bundle(for: NFSpotifyMiniPlayerView.self)
        let musicIcon = UIImage(named: "music-icon", in: bundle, compatibleWith: .none)
        
        if let albumCoverURL = albumCoverArtURL, let imageURL = URL(string: albumCoverURL) {
            trackImage.setImage(fromURL: imageURL) { (code, error) in
                if let _ = error {
                    self.trackImage.image = musicIcon
                }
            }
        }else{
            trackImage.image = musicIcon
        }
    }
    
    private func loadImageFromTrack(_ track: NFSpotifyTrack) {
        
        let bundle = Bundle(for: NFSpotifyMiniPlayerView.self)
        let musicIcon = UIImage(named: "music-icon", in: bundle, compatibleWith: .none)
        
        if track.soundType == .musicLibrary, let albumImage = track.albumImage {
            trackImage.image = albumImage
        }else if let album = track.album, let largeImageURL = album.largeImageURL, let imageURL = URL(string: largeImageURL) {
            trackImage.setImage(fromURL: imageURL) { (code, error) in
                if let _ = error {
                    self.trackImage.image = musicIcon
                }
            }
        }else{
            trackImage.image = musicIcon
        }
    }
}

// MARK: - Animation

extension NFSpotifyMiniPlayerView {

    public func show(isAnimated animated: Bool = true) {
        
        DispatchQueue.main.async {
            self.isHidden = false
            
            if animated {
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                UIView.animate(withDuration: self.animationDuration) {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.delegate.musicMiniPlayerViewDidShow(self)
                }
            }else{
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.delegate.musicMiniPlayerViewDidShow(self)
            }
        }
    }
    
    public func hide(isAnimted animated: Bool = true) {
        
        DispatchQueue.main.async {
            if animated {
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                }) { (isFinished) in
                    self.isHidden = true
                    self.delegate.musicMiniPlayerViewDidClose(self)
                }
            }else{
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                self.isHidden = true
                self.delegate.musicMiniPlayerViewDidClose(self)
            }
        }
    }
}

// MARK: Controls

extension NFSpotifyMiniPlayerView {
    
    public func updateFrame(_ frame: CGRect) {
        
        DispatchQueue.main.async {
            self.frame = frame
            self.layoutIfNeeded()
        }
    }
    
    public func updateTrack(_ track: NFSpotifyTrack!) {
        
        DispatchQueue.main.async {
            if let track = self.track {
                if self.status == .caching {
                    self.titleLbl.text = "Loading…"
                    self.detailLbl.text = track.name
                }else{
                    self.titleLbl.text = track.name
                    
                    if let artist = track.artists.first {
                        self.detailLbl.text = artist.name
                    }else{
                        self.detailLbl.text = ""
                    }
                }
                
                self.loadImageFromTrack(track)
            }else{
                self.titleLbl.text = "Select Track"
                self.detailLbl.text = "Music"
                
                let bundle = Bundle(for: NFSpotifyMiniPlayerView.self)
                let musicIcon = UIImage(named: "music-icon", in: bundle, compatibleWith: .none)
                self.trackImage.image = musicIcon
            }
        }
    }
    
    public func updateStatus(_ status: NFSpotifyMediaPlayerStatus) {
        
        // force to start on main thread
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = status != .caching // hide if caching
            self.playPauseButton.isHidden = status == .caching // hide if caching
            self.playPauseButton.isSelected = status == .playing
            
            switch status {
            case .caching:
                self.activityIndicator.startAnimating()
            default:
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func resetPlayer() {
        
        track = nil
    }
}
