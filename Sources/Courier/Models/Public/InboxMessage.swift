//
//  InboxMessage.swift
//  
//
//  Created by https://github.com/mikemilla on 3/10/23.
//

import Foundation

/**
 The model used to structure CourierInbox messages
 */
@objc public class InboxMessage: NSObject, Codable {
    
    // MARK: Properties
    
    @objc public let messageId: String
    @objc public let title: String?
    @objc public let body: String?
    @objc public let preview: String?
    @objc public let created: String?
    @objc public let actions: [InboxAction]?
    
    internal var archived: Bool?
    internal var read: String?
    
    public init(title: String?, body: String?, preview: String?, created: String?, archived: Bool?, read: String?, messageId: String, actions: [InboxAction]?) {
        self.title = title
        self.body = body
        self.preview = preview
        self.created = created
        self.archived = archived
        self.read = read
        self.messageId = messageId
        self.actions = actions
    }
    
    @objc public var subtitle: String? {
        get {
            return body ?? preview
        }
    }
    
    @objc public var isRead: Bool {
        get {
            return read != nil
        }
    }
    
    internal var isOpened: Bool? = false
    
    @objc public var isArchived: Bool {
        get {
            return archived != nil
        }
    }
    
    internal func setRead() {
        if #available(iOS 15.0, *) {
            read = Date().ISO8601Format()
        } else {
            let date = Date()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions.insert(.withFractionalSeconds)
            read = formatter.string(from: date)
        }
    }
    
    @objc public var time: String {
        get {
         
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            
            guard let createdAt = created, let date = dateFormatter.date(from: createdAt) else {
                return "now"
            }
            
            return date.timeSince()
            
        }
    }
    
}

extension InboxMessage {
    
    @objc public func markAsRead() async throws {
        try await Courier.shared.inbox.readMessage(messageId: messageId)
    }
    
    @objc public func markAsRead(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await Courier.shared.inbox.readMessage(messageId: messageId)
                onSuccess?()
            } catch {
                Courier.log(error.friendlyMessage)
                onFailure?(error)
            }
        }
    }
    
    @objc public func markAsUnread() async throws {
        try await Courier.shared.inbox.unreadMessage(messageId: messageId)
    }
    
    @objc public func markAsUnread(onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await Courier.shared.inbox.unreadMessage(messageId: messageId)
                onSuccess?()
            } catch {
                Courier.log(error.friendlyMessage)
                onFailure?(error)
            }
        }
    }
    
}
