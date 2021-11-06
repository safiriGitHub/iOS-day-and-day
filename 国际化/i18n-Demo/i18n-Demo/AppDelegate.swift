//
//  AppDelegate.swift
//  i18n-Demo
//
//  Created by safiri on 2021/11/5.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let mainSb = UIStoryboard(name: "Main", bundle: nil)
        let rootViewC = mainSb.instantiateInitialViewController() as! UINavigationController
        window?.rootViewController = rootViewC
        
        return true
    }


}

