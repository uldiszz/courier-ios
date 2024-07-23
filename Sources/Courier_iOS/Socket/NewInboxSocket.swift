//
//  InboxSocket.swift
//
//
//  Created by Michael Miller on 7/23/24.
//

import Foundation

class NewInboxSocket: CourierSocket {
    
    private let options: CourierClient.Options
    
    enum NewPayloadType: String, Codable {
        case event = "event"
        case message = "message"
    }
    
    enum NewEventType: String, Codable {
        case read = "read"
        case unread = "unread"
        case markAllRead = "mark-all-read"
        case opened = "opened"
        case archive = "archive"
    }
    
    struct NewSocketPayload: Codable {
        let type: NewPayloadType
        let event: NewEventType?
    }
    
    struct NewMessageEvent: Codable {
        let event: NewEventType
        let messageId: String?
        let type: String
    }
    
    var receivedMessage: ((InboxMessage) -> Void)?
    var receivedMessageEvent: ((NewMessageEvent) -> Void)?
    
    init(options: CourierClient.Options) {
        self.options = options
        
        let url = NewInboxSocket.buildUrl(clientKey: options.clientKey, jwt: options.jwt)
        super.init(url: url)
        
        // Handle received messages
        self.onMessageReceived = { [weak self] data in
            self?.convertToType(from: data)
        }
        
    }
    
    private func convertToType(from data: String) {
        
        do {
            
            let decoder = JSONDecoder()
            let json = data.data(using: .utf8) ?? Data()
            let payload = try decoder.decode(NewSocketPayload.self, from: json)
            
            switch (payload.type) {
            case .event:
                
                let messageEvent = try decoder.decode(NewMessageEvent.self, from: json)
                receivedMessageEvent?(messageEvent)
                
            case .message:
                
                let dictionary = try json.toDictionary()
                let message = InboxMessage(dictionary)
                receivedMessage?(message)
                
            }
            
        } catch {
            self.onError?(error)
        }
        
    }
    
    func sendSubscribe(version: Int = 5) async throws {
        
        var data: [String: Any] = [
            "action": "subscribe",
            "data": [
                "channel": options.userId,
                "event": "*",
                "version": version
            ]
        ]
        
        if var dict = data["data"] as? [String: Any] {
            
            if let clientKey = self.options.clientKey {
                dict["clientKey"] = clientKey
            }
            
            if let tenantId = self.options.tenantId {
                dict["accountId"] = tenantId
            }
            
            data["data"] = dict
            
        }
        
        try await send(data)
        
    }
    
    private static func buildUrl(clientKey: String?, jwt: String?) -> String {
        var url = CourierApiClient.INBOX_WEBSOCKET
        if let jwt = jwt {
            url += "/?auth=\(jwt)"
        } else if let clientKey = clientKey {
            url += "/?clientKey=\(clientKey)"
        }
        return url
    }
    
}
