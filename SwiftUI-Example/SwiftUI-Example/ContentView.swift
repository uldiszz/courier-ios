//
//  ContentView.swift
//  SwiftUI-Example
//
//  Created by Michael Miller on 3/27/23.
//

import SwiftUI
import Courier_iOS

struct ContentView: View {
    
    let theme = CourierInboxTheme(
        messageAnimationStyle: .fade,
        unreadIndicatorBarColor: .blue,
        loadingIndicatorColor: .systemMint,
        titleFont: CourierInboxFont(
            font: UIFont(name: "Avenir Black", size: 20)!,
            color: .label
        ),
        timeFont: CourierInboxFont(
            font: UIFont(name: "Avenir Medium", size: 16)!,
            color: .label
        ),
        bodyFont: CourierInboxFont(
            font: UIFont(name: "Arial", size: 18)!,
            color: .label
        ),
        detailTitleFont: CourierInboxFont(
            font: UIFont(name: "Avenir Medium", size: 20)!,
            color: .label
        ),
        buttonStyles: CourierInboxButtonStyles(
            font: CourierInboxFont(
                font: UIFont(name: "Avenir Black", size: 16)!,
                color: .white
            ),
            backgroundColor: .red,
            cornerRadius: 0
        ),
        cellStyles: CourierInboxCellStyles(
            separatorStyle: .none,
            separatorInsets: .zero
        )
    )
    
    init() {
        
        Task {
            
            let COURIER_ACCESS_TOKEN = "pk_prod_H48Y2E9VV94YP5K60JAYPGY3M3NH"
            let COURIER_CLIENT_KEY = "YWQxN2M2ZmMtNDU5OS00ZThlLWE4NTktZDQ4YzVlYjkxM2Mx"
            
            try await Courier.shared.signIn(
                accessToken: COURIER_ACCESS_TOKEN,
                clientKey: COURIER_CLIENT_KEY,
                userId: "mike"
            )
            
        }
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CourierInboxView(
                    lightTheme: theme,
                    darkTheme: theme,
                    didClickInboxMessageAtIndex: { message, index in
                        print(message, index)
                        message.isRead ? message.markAsUnread() : message.markAsRead()
                    },
                    didClickInboxActionForMessageAtIndex: { action, message, index in
                        print(action, message, index)
                    },
                    didScrollInbox: { scrollview in
                        print(scrollview.contentOffset.y)
                    }
                )
            }
            .navigationTitle("Courier Inbox")
            .ignoresSafeArea()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
