//
//  NetworkFacade.swift
//  TMDB
//
//  Created by Roman Osadchuk on 6/18/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class NetworkFacade {
    
//MARK: - Typealiases
    typealias GetTracksResponseHandler = (Array<TrackModel>?, Error?)->Swift.Void
    
//MARK: - Public
    
    class func getTracks(cursor: Int, limit: Int, responseHandler: @escaping GetTracksResponseHandler) {
        
        guard let url = URLProvider.getTracks(for: cursor, limit: limit) else {
            print("Error composing URL")
            return
        }

        Alamofire.request(url).responseJSON { (response) in
            if let json = response.result.value as? [String : Any],
                let body = json["body"] as? [String : Any],
                let tracks = body["tracks"] as? [[String : Any]]
            {
                let trackList = Mapper<TrackModel>().mapArray(JSONArray: tracks) ?? [TrackModel]()
                responseHandler(trackList, nil)
            } else {
                responseHandler(nil, response.error)
            }
        }
        
    }
    
}
