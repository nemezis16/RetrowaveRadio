//
//  URLComposer.swift
//  TMDB
//
//  Created by Roman Osadchuk on 6/17/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import Foundation

class URLComposer {
    
    var scheme: String!
    var host: String!
    var pathComponents: [String]?
    var queryItems: [String : String]?
    
    func getComposed() -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        
        if let pathComponents = pathComponents {
            urlComponents.path = "/" + pathComponents.joined(separator: "/")
        }
        
        if let queryItemsDict = queryItems {
            var queryItems = [URLQueryItem]()
            for (key, value) in queryItemsDict {
                let queryItem = URLQueryItem(name: key, value: value)
                queryItems.append(queryItem)
                }
            urlComponents.queryItems = queryItems
        }
        
        return urlComponents.url
    }
    
}
