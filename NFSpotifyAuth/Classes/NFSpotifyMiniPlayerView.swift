//
//  NFSpotifyMiniPlayerView.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/12/20.
//

import Foundation

public protocol NFSpotifyMiniPlayerViewDelegate: NSObjectProtocol {
    
    func musicMiniPlayerViewDidTapToggle(_ view: NFSpotifyMiniPlayerView)
    
    func musicMiniPlayerViewDidShow(_ view: NFSpotifyMiniPlayerView)
    func musicMiniPlayerViewDidClose(_ view: NFSpotifyMiniPlayerView)
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
    
    public var progressTintColor: UIColor = UIColor(red: 16, green: 23, blue: 197, alpha: 1) {
        didSet {
            progress.progressTintColor = progressTintColor
        }
    }

    public var trackTintColor: UIColor = UIColor(red: 232, green: 232, blue: 232, alpha: 1) {
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
    
    public var detailLblTextColor: UIColor = UIColor(red: 146, green: 146, blue: 146, alpha: 1) {
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
    
    private func prepareMiniPlayer() {
        
        clipsToBounds = true
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        toggleButton.setBackgroundImage(generateImageWithColor(color), for: .highlighted) // add responsive tap effect on toggle
        
        playPauseButton.setImage(UIImage(named: "PlayButton"), for: .normal) // currently at default state
        playPauseButton.setImage(UIImage(named: "PauseButton"), for: .selected) // currently at playing state
        
        progress.progressTintColor = progressTintColor
        progress.trackTintColor = trackTintColor
        progress.progress = 0.0
        
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
