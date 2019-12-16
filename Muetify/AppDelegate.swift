//
//  AppDelegate.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/6/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print(error)
        }
        
        application.beginReceivingRemoteControlEvents()
        return true
    }

}

