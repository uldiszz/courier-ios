//
//  ViewController.swift
//  Example
//
//  Created by Michael Miller on 11/17/22.
//

import UIKit
import Courier

class ViewController: UIViewController {
    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var apnsSwitch: UISwitch!
    @IBOutlet weak var fcmSwitch: UISwitch!
    
    @IBAction func authButtonAction(_ sender: Any) {
        
        if let _ = Courier.shared.userId {
            
            Task {
            
                try await Courier.shared.signOut()
                refresh()
                
            }
            
        } else {
            
            showInputAlert(title: "Sign in", placeHolder: "Enter Courier User Id", action: "Sign In") { userId in
                
                Task {
                    
                    try await Courier.shared.signIn(
                        accessToken: Env.COURIER_ACCESS_TOKEN,
                        clientKey: Env.COURIER_CLIENT_KEY,
                        userId: userId
                    )
                    
                    self.refresh()
                    try await Courier.requestNotificationPermission()
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func sendPushAction(_ sender: Any) {
        
        Task {
            
            var providers: [CourierProvider] = []
            
            if (apnsSwitch.isOn) {
                providers.append(.apns)
            }
            
            if (fcmSwitch.isOn) {
                providers.append(.fcm)
            }
            
            let messageProviders = providers.map { $0.rawValue }.joined(separator: " and ")
            
            if let userId = Courier.shared.userId {
                
                if (!providers.isEmpty) {
                    try await Courier.shared.sendPush(
                        authKey: Env.COURIER_AUTH_KEY,
                        userId: userId,
                        title: "Hey \(userId)!",
                        message: "This is a test push sent through \(messageProviders)",
                        providers: providers
                    )
                }
                
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        
        let l1 = Courier.shared.addInboxListener(
            onInitialLoad: {
                print("Listener 1 Loading")
            },
            onError: { error in
                print("Listener 1 Error: \(error)")
            },
            onMessagesChanged: { messages in
                print("Listener 1 Messages: \(messages.count)")
            }
        )
        
//        let l2 = Courier.shared.addInboxListener(
//            onInitialLoad: {
//                print("Listener 2 Loading")
//            },
//            onError: { error in
//                print("Listener 2 Error: \(error)")
//            },
//            onMessagesChanged: { messages in
//                print("Listener 2 Messages: \(messages.count)")
//            }
//        )
        
    }
    
    private func refresh() {
        
        if let userId = Courier.shared.userId {
            
            authButton.setTitle("Sign Out", for: .normal)
            authLabel.text = "Courier User Id: \(userId)"
            sendButton.isEnabled = true
            
        } else {
            
            authButton.setTitle("Sign In", for: .normal)
            authLabel.text = "No Courier User Id Found"
            sendButton.isEnabled = false
            
        }
        
    }
    
}

