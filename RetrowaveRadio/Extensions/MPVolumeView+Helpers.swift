//
//  MPVolumeView+Helpers.swift
//  RetrowaveRadio
//
//  Created by Roman Osadchuk on 7/19/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import MediaPlayer

extension MPVolumeView {
    var volumeSlider: UISlider {
        self.showsRouteButton = false
        self.showsVolumeSlider = true
        var slider = UISlider()
        for subview in self.subviews {
            if subview.isKind(of: UISlider.self){
                slider = subview as! UISlider
                slider.isContinuous = false
                slider.minimumTrackTintColor = UIColor.purpleNeonColor
                slider.thumbTintColor = UIColor.purpleNeonColor
                slider.maximumTrackTintColor = UIColor.black.withAlphaComponent(0.33)
                (subview as! UISlider).value = AVAudioSession.sharedInstance().outputVolume
                return slider
            }
        }
        return slider
    }
}
