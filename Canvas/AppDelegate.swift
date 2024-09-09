//
//  AppDelegate.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let canvasVC = HomeVC()
        
        let navController = UINavigationController(rootViewController: canvasVC)
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        window?.overrideUserInterfaceStyle = .dark
        
        return true
    }
}

