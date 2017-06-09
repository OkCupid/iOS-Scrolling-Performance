//
//  AppDelegate.swift
//  ScrollingPerformance
//
//  Created by Jordan Guggenheim on 6/9/17.
//  Copyright © 2017 OkCupid. All rights reserved.
//

let kIsOptimized = true

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootViewController = OKConversationViewController(assetFactory: OKConversationAssetFactory(),
                                                              sizingFactory: OKConversationSizingFactory(),
                                                              messageClient: OKConversationMessageClient())
        
        window?.rootViewController = UINavigationController(rootViewController: rootViewController)
        window?.makeKeyAndVisible()
        
        return true
    }
    
}
