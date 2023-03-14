//
//  StyledInboxViewController.swift
//  Example
//
//  Created by Michael Miller on 3/14/23.
//

import UIKit
import Courier

class StyledInboxViewController: UIViewController, CourierInboxDelegate {
    
    let courierInbox = CourierInbox()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textColor = UIColor(red: 42 / 255, green: 21 / 255, blue: 55 / 255, alpha: 100)
        let primaryColor = UIColor(red: 136 / 255, green: 45 / 255, blue: 185 / 255, alpha: 100)
        let secondaryColor = UIColor(red: 234 / 255, green: 104 / 255, blue: 102 / 255, alpha: 100)
        
        courierInbox.lightTheme = CourierInboxTheme(
            messageAnimationStyle: .top,
            unreadIndicatorBarColor: secondaryColor,
            loadingIndicatorColor:  primaryColor,
            titleFont: CourierInboxFont(
                font: UIFont(name: "Courier New Bold", size: 20)!,
                color: textColor
            ),
            timeFont: CourierInboxFont(
                font: UIFont(name: "Courier New", size: 16)!,
                color: textColor
            ),
            bodyFont: CourierInboxFont(
                font: UIFont(name: "Courier New", size: 18)!,
                color: textColor
            ),
            detailTitleFont: CourierInboxFont(
                font: UIFont(name: "Courier New", size: 20)!,
                color: textColor
            ),
            buttonStyles: CourierInboxButtonStyles(
                font: CourierInboxFont(
                    font: UIFont(name: "Courier New Bold", size: 16)!,
                    color: .white
                ),
                backgroundColor: primaryColor
            ),
            cellStyles: CourierInboxCellStyles(
                separatorStyle: .none
            )
        )
        
        courierInbox.darkTheme = CourierInboxTheme(
            messageAnimationStyle: .top,
            unreadIndicatorBarColor: secondaryColor,
            loadingIndicatorColor:  .white,
            titleFont: CourierInboxFont(
                font: UIFont(name: "Courier New Bold", size: 20)!,
                color: .white
            ),
            timeFont: CourierInboxFont(
                font: UIFont(name: "Courier New", size: 16)!,
                color: .white
            ),
            bodyFont: CourierInboxFont(
                font: UIFont(name: "Courier New", size: 18)!,
                color: .white
            ),
            detailTitleFont: CourierInboxFont(
                font: UIFont(name: "Courier New", size: 20)!,
                color: .white
            ),
            buttonStyles: CourierInboxButtonStyles(
                font: CourierInboxFont(
                    font: UIFont(name: "Courier New Bold", size: 16)!,
                    color: primaryColor
                ),
                backgroundColor: .white
            ),
            cellStyles: CourierInboxCellStyles(
                separatorStyle: .none
            )
        )

        courierInbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierInbox)
        
        courierInbox.delegate = self
        
        NSLayoutConstraint.activate([
            courierInbox.topAnchor.constraint(equalTo: view.topAnchor),
            courierInbox.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            courierInbox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierInbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        title = "Styled Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll))
        
    }
    
    @objc private func readAll() {
        Courier.shared.readAllInboxMessages()
    }
    
    func didClickInboxMessageAtIndex(message: InboxMessage, index: Int) {
        message.isRead ? message.markAsUnread() : message.markAsRead()
        print(index, message)
    }
    
    func didClickButtonForInboxMessage(message: InboxMessage, index: Int) {
        print(index, message)
    }
    
    func didScrollInbox(scrollView: UIScrollView) {
         print(scrollView.contentOffset.y)
    }

}
