//
//  CMTime+Helpers.swift
//  RetrowaveRadio
//
//  Created by Roman Osadchuk on 8/14/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import AVFoundation

extension CMTime {
    var humanReadable: String {
        let duration = CMTimeGetSeconds(self)
        let date = Date(timeIntervalSince1970: duration)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = duration / 360 >= 1 ? "hh:mm:ss" : "mm:ss"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
