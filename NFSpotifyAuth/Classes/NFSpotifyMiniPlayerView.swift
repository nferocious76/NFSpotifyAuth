//
//  NFSpotifyMiniPlayerView.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/12/20.
//

import Foundation

public protocol NFSpotifyMiniPlayerViewDelegate: NSObjectProtocol {
    
    func musicMiniPlayerViewDidShow(_ view: NFSpotifyMiniPlayerView)
    func musicMiniPlayerViewDidClose(_ view: NFSpotifyMiniPlayerView)
    
    func musicMiniPlayerViewDidTapToggle(_ view: NFSpotifyMiniPlayerView)
    func musicMiniPlayerViewDidTapPlay(_ view: NFSpotifyMiniPlayerView)
}

public class NFSpotifyMiniPlayerView: UIView {
    
    @IBOutlet weak private var progress: UIProgressView! // Playback progress bar
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet weak private var titleLbl: UILabel!
    @IBOutlet weak private var detailLbl: UILabel!
    
    @IBOutlet weak private var trackImage: UIImageView!
    @IBOutlet weak private var sourceBadge: UIImageView!
    
    @IBOutlet weak private var playPauseButton: UIButton!
    @IBOutlet weak private var toggleButton: UIButton! // view toggle handler
    
    // MARK: - Declarations
    
    public weak var delegate: NFSpotifyMiniPlayerViewDelegate!
    public var animationDuration: TimeInterval = 0.33
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    public var progressTintColor: UIColor = .blue {
        didSet {
            progress.progressTintColor = progressTintColor
        }
    }

    public var trackTintColor: UIColor = UIColor(red: 146, green: 146, blue: 146, alpha: 1) {
        didSet {
            progress.trackTintColor = trackTintColor
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

    public class func instance(withDelegate delegate: NFSpotifyMiniPlayerViewDelegate) -> NFSpotifyMiniPlayerView {
        
        let bundle = Bundle(for: NFSpotifyMiniPlayerView.self)
        let nib = UINib(nibName: "NFSpotifyMiniPlayerView", bundle: bundle)
        let miniPlayer = nib.instantiate(withOwner: nil, options: nil).first as! NFSpotifyMiniPlayerView
        miniPlayer.delegate = delegate
        
        return miniPlayer
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
     
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
        
        progress.progressTintColor = progressTintColor
        progress.trackTintColor = trackTintColor
        progress.progress = 0.2
        
        trackImage.clipsToBounds = true
        trackImage.layer.cornerRadius = 1.0
        trackImage.contentMode = .scaleAspectFill
        
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
    }
    
    @IBAction private func toggleButton(_ sender: UIButton) {

        self.delegate.musicMiniPlayerViewDidTapToggle(self)
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
    
    public func updateTrack(_ track: NFSpotifyTrack) {
        
        
        titleLbl.text = "Loading…"
        detailLbl.text = track.name
        
        
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
}
