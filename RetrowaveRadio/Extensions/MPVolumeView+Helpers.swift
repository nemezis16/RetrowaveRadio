//
//  MPVolumeView+Helpers.swift
//  RetrowaveRadio
//
//  Created by Roman Osadchuk on 7/19/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import MediaPlayer

extension MPVolumeView {
    var volumeSlider:UISlider {
        self.showsRouteButton = false
        self.showsVolumeSlider = false
        self.isHidden = true
        var slider = UISlider()
        for subview in self.subviews {
            if subview.isKind(of: UISlider.self){
                slider = subview as! UISlider
                slider.isContinuous = false
                (subview as! UISlider).value = AVAudioSession.sharedInstance().outputVolume
                return slider
            }
        }
        return slider
    }
}
