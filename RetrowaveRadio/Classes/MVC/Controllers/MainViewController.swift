//
//  MainViewController.swift
//  RetrowaveRadio
//
//  Created by Roman Osadchuk on 7/8/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AlamofireImage
import MediaPlayer

class MainViewController: UIViewController {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var cassetteImageView: UIImageView!
    
    @IBOutlet var trackTitleLabel: UILabel!
    @IBOutlet var timePassedLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    
    @IBOutlet var horizontalSlider: MPVolumeView!
    
    @IBOutlet var playImageView: UIImageView!
    
    var timeObserverToken: Any?
    var player: AVPlayer?
    var cursor = 0
    var tracks = [TrackModel]()
    
    func setupCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.handlePauseButtonTap(nil)
            return .success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.handlePauseButtonTap(nil)
            return .success
        }
    
        commandCenter.previousTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.playPreviousTrack()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.playNextTrack()
            return .success
        }
        
    }
    
//MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = horizontalSlider.volumeSlider
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            setupCommandCenter()
        } catch {
            print(error)
        }
        getTracks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            UIApplication.shared.endReceivingRemoteControlEvents()
        } catch {
            print(error)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
//MARK: - Action
    
    @IBAction func handlePreviousButtonTap(_ sender: UIButton) {
        playPreviousTrack()
    }
    
    @IBAction func handleNextButtonTap(_ sender: UIButton) {
        playNextTrack()
    }
    
    @IBAction func handlePauseButtonTap(_ sender: UIButton?) {
        if player?.rate == 0 {
            player?.play()
            playImageView.image = #imageLiteral(resourceName: "pause-button")
        } else {
            player?.pause()
            playImageView.image = #imageLiteral(resourceName: "play-button")
        }
    }
 
//MARK: - Private
    
    fileprivate func getTracks() {
        NetworkFacade.getTracks(cursor: cursor, limit: 100) { (tracks, error) in
            self.tracks = tracks ?? [TrackModel]()
            self.playPreviousTrack()
        }
    }
    
    fileprivate func playTrackForCursor() {
        if var streamURL = self.tracks[cursor].streamUrl {
            streamURL = Constants.SchemeHTTP + "://" + Constants.API.Host + streamURL
            if let url = URL(string: streamURL) {
                self.playTrack(url: url)
            }
        }
    }
    
    fileprivate func setupUIForCursor() {
        let currentTrack = self.tracks[cursor]
        if var artworkUrl = currentTrack.artworkUrl {
            artworkUrl = Constants.SchemeHTTP + "://" + Constants.API.Host + artworkUrl
            if let url = URL(string: artworkUrl) {
                self.updateInfoCenter()
                self.backgroundImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: false, completion: { (dataResponse) in
                    self.cassetteImageView.image = dataResponse.value
                    self.updateInfoCenter()
                })
            }
        }
        if let trackTitle = currentTrack.title {
            trackTitleLabel.text = trackTitle
        }
    }
    
    fileprivate func playTrack(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        if self.timeObserverToken != nil {
            player?.removeTimeObserver(self.timeObserverToken as Any)
            player?.removeObserver(self, forKeyPath: "status")
        }
        player = AVPlayer(playerItem: playerItem)
        player?.addObserver(self, forKeyPath: "status", options: .init(rawValue: 0), context: nil)
        var playerStart = true
        self.timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main) {
            [weak self] time in
            guard let strongSelf = self else { return }

            let duration = CMTimeGetSeconds(playerItem.duration)
            if playerStart && duration > 0 {
                strongSelf.totalTimeLabel.text = " / " + playerItem.duration.humanReadable
                playerStart = false
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
//                    strongSelf.playNextTrack()
//                })
            }
            if time.value > 0 {
                strongSelf.timePassedLabel.text = playerItem.currentTime().humanReadable
            }
        }

//        if let player = player {
//            player.play()
//        }
    }
    
    fileprivate func playNextTrack() {
        setDefaultTimerLabel()
        cursor += 1
        playTrackForCursor()
        setupUIForCursor()
    }
    
    fileprivate func playPreviousTrack() {
        if cursor != 0 { cursor -= 1 }
        playTrackForCursor()
        setupUIForCursor()
    }
    
    fileprivate func setDefaultTimerLabel() {
        self.timePassedLabel.text = "00:00"
        self.totalTimeLabel.text = " / 00:00"
    }
    
    fileprivate func updateInfoCenter() {
        let song = self.tracks[cursor]
        guard let songTitle = song.title else { return }
        var playingInfo = [MPMediaItemPropertyTitle : songTitle,
                           MPNowPlayingInfoPropertyPlaybackRate : 1.0] as [String : Any]
        if let image = self.cassetteImageView.image {
            let artwork = MPMediaItemArtwork(image: image)
            playingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if ((object as? AVPlayer) == self.player) && (keyPath == "status") {
            switch player!.status {
            case .failed:
                print("Failed")
            case .readyToPlay:
                print("ReadyToPlay")
                self.player?.play()
            case .unknown:
                print("Unknown")
            }
        }
    }
    
//MARK: - Observers
    
    func itemDidFinishPlaying(notification: Notification) {
        self.playNextTrack()
    }

}
