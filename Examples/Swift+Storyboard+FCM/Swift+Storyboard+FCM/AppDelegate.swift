//
//  AppDelegate.swift
//  Swift+Storyboard+FCM
//
//  Created by Michael Miller on 7/21/22.
//

import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: CourierDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize your firebase project
        // 1. Follow these steps: https://firebase.google.com/docs/ios/setup
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // Be sure you have created a new APNS key and have uploaded it here before you get started
        // 2. Create new APNS key here: https://developer.apple.com/account/resources/authkeys/add
        // 3. Upload your APNS key to your Firebase Account: https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/cloudmessaging
        // 4. Get the Firebase Service Key JSON from here (Click "Generate New Private Key"): https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/serviceaccounts/adminsdk
        // 5. Upload the Firebase Service Key JSON to here: https://app.courier.com/channels/firebase-fcm
        
        // Initialize the Courier SDK by setting your authorization key
        // 6. Get your api key from here: https://app.courier.com/settings/api-keys
        Courier.shared.authorizationKey = your_auth_key
        
        return true
    }
    
    // MARK: Courier Notification Functions
    
    override func pushNotificationReceivedInForeground(message: [AnyHashable : Any], presentAs showForegroundNotificationAs: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Push Received")
        print(message)
        
        // ⚠️ Customize this to be what you would like
        // Pass an empty array to this if you do not want to use it
        showForegroundNotificationAs([.list, .badge, .banner, .sound])
        
        // ⚠️ For demo purposes only
        showMessageAlert(title: "Push Received", message: "\(message)")
        
    }
    
    override func pushNotificationOpened(message: [AnyHashable : Any]) {
        
        print("Push Opened")
        print(message)
        
        // ⚠️ For demo purposes only
        showMessageAlert(title: "Push Opened", message: "\(message)")
        
    }

}

extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      if let token = fcmToken {
          Courier.shared.setFCMToken(token)
      }
  }

}
