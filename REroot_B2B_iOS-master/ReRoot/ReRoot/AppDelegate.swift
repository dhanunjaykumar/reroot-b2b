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
import Siren
import Firebase
import UserNotifications
import Firebase
import AWSS3
import AVFoundation
import AVKit
import AWSCore


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let reachability = Reachability()!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }

        UserDefaults.standard.set(true, forKey: "shouldFetchSelectedProject")

        FirebaseApp.configure()

        UIApplication.shared.applicationIconBadgeNumber = 0

        let urlStrig : String = UserDefaults.standard.value(forKey: "url") as? String ?? ""

        
        Siren.shared.wail() // Line 2

        if(UserDefaults.standard.object(forKey: "Unit Description Enabled") == nil){
            UserDefaults.standard.set(true, forKey: "Unit Description Enabled")
            UserDefaults.standard.synchronize()
        }
        
        if(urlStrig.count == 0){
            UserDefaults.standard.set("http://dashboard.reroot.in", forKey: "url")
            UserDefaults.standard.set("PRODUCTION", forKey: "mode")
            UserDefaults.standard.synchronize()
        }
        
        do  {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            //TODO
        }

        
//        reachability.whenReachable = { reachability in //To do something if on lauch if network is there?
//            if reachability.connection == .wifi {
//                    print("Reachable via WiFi")
//            } else {
//                print("Reachable via Cellular")
//            }
//        }
//        reachability.whenUnreachable = { _ in
//            print("Not reachable")
//        }
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
        
        self.setUpAWSS3()

        #if DEBUG
//            Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
//        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif
        
        Siren.shared.presentationManager = PresentationManager(forceLanguageLocalization: .english)
        
        // Siren is a singleton
        _ = Siren.shared
        
//        Fabric.with([Crashlytics.self])

//        print(applicationDirectoryPath())
        self.configureNotification(application)
        self.showAppUpdateAlert()
        
        if(PermissionsManager.shared.isSuperUser()){ // ** Mandatory check
            
        }
//        FirebaseApp.configure()

        return true
    }
    /// An example on how to customize multiple managers at once.
    func showAppUpdateAlert() {
        let siren = Siren.shared
        siren.presentationManager = PresentationManager(alertTintColor: .brown,
                                                        appName: "REroot",
                                                        alertTitle: "Update Now",
                                                        forceLanguageLocalization: .english)
        siren.rulesManager = RulesManager(majorUpdateRules: .critical,
                                          minorUpdateRules: .critical,
                                          patchUpdateRules: .critical,
                                          revisionUpdateRules: .critical)
        
        Siren.shared.wail { results in
            switch results {
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    func applicationDirectoryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String
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
        
//        Siren.shared.checkVersion(checkType: .immediately)

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
//        Siren.shared.checkVersion(checkType: .daily)

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        UserDefaults.standard.set(false, forKey: "shouldFetchSelectedProject")
        self.saveContext()
    }

    // MARK: - FCM
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo["gcmMessageIDKey"] { //gcmMessageIDKey
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo["gcmMessageIDKey"] { //gcmMessageIDKey
//            print("Message ID: \(messageID)")
        }
        
//        print(userInfo["aps"])
        
        let tempDict : Dictionary<String,Any> = userInfo["aps"] as! Dictionary<String, Any>
        
//        print(tempDict)
        
        // Print full message.
        print(userInfo)
        let alertInfo : Dictionary<String,String> = tempDict["alert"] as! Dictionary<String,String>
        
        print(alertInfo)
        
        let title = alertInfo["title"]
        let body = alertInfo["body"]
        
        let alertController = UIAlertController(title: NSLocalizedString(title!, comment: ""), message: NSLocalizedString(body!, comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(
            alertController,
            animated: true,
            completion: nil
        )
        NotificationCenter.default.post(name: NSNotification.Name("SetUpCall"), object: nil)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    func configureNotification(_ application: UIApplication) {
        
        /// *** FCM START ****
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        /// *** FCM END ****
    }

    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Unable to register for remote notifications: \(error.localizedDescription)")
        application.registerForRemoteNotifications()
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
        
    }

    
    @objc func internetChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            RRUtilities.sharedInstance.isNetworkAvailable = true
            NotificationCenter.default.post(name: NSNotification.Name("NotificationsCall"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("SetUpCall"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("HomeScreenSetUp"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.UPLOAD_HANDOVER_DATA), object: nil)
            break;
        case .cellular:
            print("Reachable via Cellular")
            RRUtilities.sharedInstance.isNetworkAvailable = true
            NotificationCenter.default.post(name: NSNotification.Name("NotificationsCall"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("SetUpCall"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("HomeScreenSetUp"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.UPLOAD_HANDOVER_DATA), object: nil)
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
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
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
//extension AppDelegate: SirenDelegate {
//    // Returns a localized message to this delegate method upon performing a successful version check
//    func sirenDidDetectNewVersionWithoutAlert(message: String, updateType: UpdateType) {
//        print("\(message)")
//    }
//}
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcmMessageIDKey"] { //gcmMessageIDKey
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
//        print(userInfo["aps"])
        
        let notificationDict: Dictionary<String,Any> = userInfo["aps"] as! Dictionary<String,Any>
        let alertInfo : Dictionary<String,String> = notificationDict["alert"] as! Dictionary<String,String>
        
        print(alertInfo)
        
        let title = alertInfo["title"]
        let body = alertInfo["body"]
        
        let alertController = UIAlertController(title: NSLocalizedString(title!, comment: ""), message: NSLocalizedString(body!, comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(
            alertController,
            animated: true,
            completion: nil
        )

        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo["gcmMessageIDKey"] { //gcmMessageIDKey
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
//        print(userInfo["aps"])
        let notificationDict: Dictionary<String,Any> = userInfo["aps"] as! Dictionary<String,Any>
        let alertInfo : Dictionary<String,String> = notificationDict["alert"] as! Dictionary<String,String>
        
//        print(alertInfo)
        
        let title = alertInfo["title"]
        let body = alertInfo["body"]
        
        let alertController = UIAlertController(title: NSLocalizedString(title!, comment: ""), message: NSLocalizedString(body!, comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(
            alertController,
            animated: true,
            completion: nil
        )
        NotificationCenter.default.post(name: NSNotification.Name("NotificationsCall"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("SetUpCall"), object: nil)
        completionHandler()
    }
    // MARK: - AWS S3
    func setUpAWSS3(){
        
        let s3Config = RRUtilities.sharedInstance.model.getS3Config()
        
        if(s3Config == nil || s3Config?.accessKeyId == nil)
        {
            return
        }
//        let accessKey = s3Config!.accessKeyId!
//        let secretKey = s3Config!.secretAccessKey!
        
//        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
//        let configuration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
        
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:AWSRegionType.APSouth1,
                                                                identityPoolId:"ap-south-1:dcf659d0-1fb4-4041-b392-15869ad0ae04")
        
        let configuration = AWSServiceConfiguration(region:AWSRegionType.APSouth1, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
//        AWSS3PreSignedURLBuilder.register(with:configuration!, forKey: accessKey)
        
//        AWSS3PreSignedURLBuilder.register(with: AWSS3TransferUtility.default().configuration, forKey: accessKey)
//        let presignedURLBuilder = AWSS3PreSignedURLBuilder.s3PreSignedURLBuilder(forKey: "USEast1S3PreSignedURLBuilder")


//        AWSS3PreSignedURLBuilder.register(with:configuration!, forKey: accessKey)
        
//        AWSS3PreSignedURLBuilder.confi

    }
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        
//        AWSMobileClient.sharedInstance().initialize { (userState, error) in
//            guard error == nil else {
//                print("Error initializing AWSMobileClient. Error: \(error!.localizedDescription)")
//                return
//            }
//            print("AWSMobileClient initialized.")
//        }
        
        //provide the completionHandler to the TransferUtility to support background transfers.
        AWSS3TransferUtility.interceptApplication(application,
                                                  handleEventsForBackgroundURLSession: identifier,
                                                  completionHandler: completionHandler)
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
        
        print(Messaging.messaging().fcmToken)
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("Received data message: \(remoteMessage.appData)")
//    }
    // [END ios_10_data_message]
}



