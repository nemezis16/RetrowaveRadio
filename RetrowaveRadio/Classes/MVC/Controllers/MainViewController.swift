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
    
    var player: AVPlayer?
    var cursor = 0
    var tracks = [TrackModel]()
    
//MARK: - LifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
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
    
    @IBAction func handlePauseButtonTap(_ sender: UIButton) {
        if player?.rate == 0 {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    @IBAction func handleVolumeChangesSlide(_ sender: UISlider) {
        
    }
    
//MARK: - Private
    
    fileprivate func getTracks() {
        NetworkFacade.getTracks(cursor: cursor, limit: 100) { (tracks, error) in
            self.tracks = tracks ?? [TrackModel]()
            self.playTrackForCursor()
            self.setupUIForCursor()
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
                self.backgroundImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
                self.cassetteImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)

            }
        }
        if let trackTitle = currentTrack.title {
            trackTitleLabel.text = trackTitle
        }
    }
    
    fileprivate func playTrack(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        player = AVPlayer(playerItem: playerItem)
        if let player = player {
            player.play()
        }
    }
    
    func playNextTrack() {
        cursor += 1
        playTrackForCursor()
        setupUIForCursor()
    }
    
    func playPreviousTrack() {
        if cursor != 0 { cursor -= 1 }
        playTrackForCursor()
        setupUIForCursor()
    }
    
//MARK: - Observers
    
    func itemDidFinishPlaying(notification: Notification) {
        self.playNextTrack()
    }

}
