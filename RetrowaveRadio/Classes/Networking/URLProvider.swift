//
//  URLProvider.swift
//  TMDB
//
//  Created by Roman Osadchuk on 6/17/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import Foundation

class URLProvider {
    
    class func getTracks(for cursor: Int, limit: Int) -> URL? {
        let urlComposer = URLComposer()
        urlComposer.scheme = Constants.SchemeHTTP
        urlComposer.host = Constants.API.Host
        urlComposer.pathComponents = [Constants.API.Name, Constants.API.Version, Constants.Tracks.Path]
        urlComposer.queryItems = [Constants.Tracks.Cursor : String(cursor),Constants.Tracks.Limit : String(limit)]
        let url = urlComposer.getComposed()
        
        return url
    }
    
}
