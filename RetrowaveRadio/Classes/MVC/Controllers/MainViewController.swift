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

class MainViewController: UIViewController {

    var player: AVPlayer?
    var cursor = 0
    var tracks = [TrackModel]()
    
    @IBOutlet var backgroundImageView: UIImageView!
    
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
        if var artworkUrl = self.tracks[cursor].artworkUrl {
            artworkUrl = Constants.SchemeHTTP + "://" + Constants.API.Host + artworkUrl
            if let url = URL(string: artworkUrl) {
                self.backgroundImageView.af_setImage(withURL: url)
            }
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
    
//MARK: - Observers
    
    func itemDidFinishPlaying(notification: Notification) {
        cursor += 1
        playTrackForCursor()
    }

}
