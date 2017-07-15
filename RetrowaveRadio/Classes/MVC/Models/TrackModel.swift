//
//  TrackModel.swift
//  RetrowaveRadio
//
//  Created by Roman Osadchuk on 7/8/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import Foundation
import ObjectMapper

class TrackModel: Mappable {
    
    var id: String?
    var title: String?
    var duration: Int?
    var streamUrl: String?
    var artworkUrl: String?

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        duration <- map["duration"]
        streamUrl <- map["streamUrl"]
        artworkUrl  <- map["artworkUrl"]
    }
    
}
