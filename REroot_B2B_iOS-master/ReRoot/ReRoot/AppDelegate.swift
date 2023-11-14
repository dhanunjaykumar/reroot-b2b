//
//  AppDelegate.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import Reachability
import IQKeyboardManagerSwift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let reachability = Reachability()!

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let urlStrig : String = UserDefaults.standard.value(forKey: "url") as? String ?? ""

        #if DEBUG //192.168.0.104    // edp@ukn.co.in  //reroot@123   //52.66.34.235  //192.168.1.4
            UserDefaults.standard.set("http://192.168.43.216:3000", forKey: "url")
            UserDefaults.standard.synchronize()
        #endif
        
        if(urlStrig.count == 0){
            UserDefaults.standard.set("http://13.233.30.97:3000", forKey: "url")
            UserDefaults.standard.synchronize()
        }

        reachability.whenReachable = { reachability in //To do something if on lauch if network is there?
            if reachability.connection == .wifi {
                    print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        #if swift(>=4.2)
            IQKeyboardManager.shared.enable = true //to handle keyboard events automatically
        #else
            IQKeyboardManager.shared.enable = true
            IQKeyboardManager.shared.enableDebugging = true
        #endif
        
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow

        Fabric.with([Crashlytics.self])

//        #if DEBUG
//            Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")!.load()
//        #endif
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    @objc func internetChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            RRUtilities.sharedInstance.isNetworkAvailable = true
            break;
        case .cellular:
            print("Reachable via Cellular")
            RRUtilities.sharedInstance.isNetworkAvailable = true
            break;
        case .none:
            print("Network not reachable")
            RRUtilities.sharedInstance.isNetworkAvailable = false
            break;
        }
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ReRoot")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

