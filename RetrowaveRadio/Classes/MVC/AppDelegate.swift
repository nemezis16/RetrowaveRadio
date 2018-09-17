//
//  AppDelegate.swift
//  RetrowaveRadio
//
//  Created by Roman Osadchuk on 7/6/17.
//  Copyright © 2017 RomanOsadchuk. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }
        
        return true
    }

}

