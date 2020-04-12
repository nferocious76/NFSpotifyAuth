//
//  NFSpotifyMiniPlayerView.swift
//  NFSpotifyAuth
//
//  Created by Neil Francis Hipona on 4/12/20.
//

import Foundation

public class NFSpotifyMiniPlayerView: UIView {
    
    @IBOutlet weak var progress: UIProgressView! // Playback progress bar
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailLbl: UILabel!
    
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var sourceBadge: UIImageView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton! // view toggle handler
}
