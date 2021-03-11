//
//  AppDelegate.swift
//  Missing Link
//
//  Created by Benjamin Share on 8/30/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthCore
import AWSCore
import AWSDynamoDB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isInitialized = false
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let fm = FileManager.default
        fm.changeCurrentDirectoryPath(localDir)
        let didFinishLaunching = AWSSignInManager.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        if (!isInitialized) {
            AWSSignInManager.sharedInstance().resumeSession(completionHandler: {
                (result: Any?, error: Error?) in
                if error != nil {
                    print("Result: :\(String(describing: result)) \n Error:\(String(describing: error))\n\n")
                }
            })
            isInitialized = true
        }
        
        print("Setting credentials")
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-2:6031ed60-0f0b-4c0e-ad83-284e6594c257")
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
        let objectMapperConfiguration = AWSDynamoDBObjectMapperConfiguration()

        AWSDynamoDBObjectMapper.register(with: configuration!, objectMapperConfiguration: objectMapperConfiguration, forKey: "USWest2DynamoDBObjectMapper")
        
        
        
        executeOnAppLaunch()
        return didFinishLaunching
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    // Both this and applicationWillResignActive are called on app closure. This function is used to update DBD tables with user progress data. This should be the only time this occurs.
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("App going to background")
        syncUserProgress() 
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("App terminating")
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func executeOnAppLaunch() {
        setDailyPuzzleDateFormat()
        updateDailyPuzzle()
        updatePlayPuzzles()
    }
}

