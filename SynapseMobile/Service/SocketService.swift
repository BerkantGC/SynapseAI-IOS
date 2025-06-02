//
//  SocketManagerService.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 20.11.2024.
//

import Foundation
import SwiftStomp
import SwiftUI

class SocketManagerService: ObservableObject, SwiftStompDelegate {
    
    static let shared = SocketManagerService()
    
    @Published var notifications: [NotificationModel] = []
    @Published var sessions: SessionResponse?;
    @Published var selectedSession: SessionModel?
    @Published var messages: [MessageModel] = []
    @Published var newMessage: String = ""
    @Published var proxy: ScrollViewProxy?
    
    private var swiftStomp: SwiftStomp?
    
    private func setupSocketConnection() {
        @EnvironmentKey("SOCKET_URL")
        var socketURLString :String;
        
        guard let serverURL = URL(string: socketURLString),
              let userSession = KeychainService.instance.secureGet(forKey: "SESSION"),
              let user = try? JSONDecoder().decode(User.self, from: Data(userSession.utf8))
        else {
            print("Failed to retrieve WebSocket URL or User Token.")
            return
        }
        
    
        swiftStomp = SwiftStomp(host: serverURL, headers: ["Authorization" : "Bearer \(user.token)"])
        swiftStomp?.autoReconnect = true
        swiftStomp?.delegate = self
    }
    
    func connect() {
        swiftStomp?.connect()
    }
     
    func disconnect() {
        swiftStomp?.disconnect()
    }
    
    func subscribe(to topic: String) {
        swiftStomp?.subscribe(to: topic)
    }
    
    func unsubscribe() {
        if let session_id = self.selectedSession?.session_id {
            swiftStomp?.unsubscribe(from: "/user/topic/private/\(session_id)")
            self.messages = []
        }
    }
    
    func send(body: String? = "", to topic: String)
    {
        swiftStomp?.send(body: body, to: topic)
    }
    
    func send(body: [String : String], to: String){
        swiftStomp?.send(body: body, to: to)
    }
    
    func setSeen() {
        if let session_id = self.selectedSession?.session_id {
            self.send(body: "\(session_id)", to: "/app/chat/set-seen")
        }
    }
    
    func scrollToLatestMessage() {
        if !messages.isEmpty && proxy != nil {
            withAnimation {
                self.proxy!.scrollTo(messages.last?.id, anchor: .bottom)
            }
        }
    }
    
    // MARK: - SwiftStompDelegate Methods
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        print("Disconnected from WebSocket.")
    }
    
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        DispatchQueue.main.async {
            self.subscribe(to: "/user/queue/notifications")
            self.subscribe(to: "/user/topic/private")
        }
        
        swiftStomp.send(body: "", to: "/app/get-notifications") // Ensure your server accepts empty payloads here
    }

    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String: String]) {
        guard let message = message as? String else {
            print("Received invalid message format")
            return
        }
        
        if(destination == "/user/queue/notifications"){
            DispatchQueue.main.async {
                if let notificationsRes = try? JSONDecoder().decode(NotificationsReponse.self, from: Data(message.utf8)){
                    if let notifications = notificationsRes.notifications{
                        self.notifications = notifications
                    } else if let notification = notificationsRes.notification{
                        self.notifications.append(notification)
                    } else if let deletedNotificationId = notificationsRes.deleted_notification_id {
                        self.notifications = self.notifications.filter { $0.id != deletedNotificationId }
                    }
                }
            }
            
        }
        if(destination == "/user/topic/private"){
            DispatchQueue.main.async {
                if let sessionResponse = try? JSONDecoder().decode(SessionResponse.self, from: Data(message.utf8)){
                    self.sessions = sessionResponse
                }
                
            }
        }
        
        if(destination == "/user/topic/private/\(self.selectedSession?.session_id ?? 0)"){
            if let readResponse = try? JSONDecoder().decode(ReadResponse.self, from: Data(message.utf8)) {
                if !readResponse.me{
                    self.messages = self.messages.map { message in
                        var updatedMessage = message
                        if message.me && message.seen_at == nil {
                            updatedMessage.seen_at = readResponse.seen_at
                        }
                        return updatedMessage
                    }
                }
            }

            DispatchQueue.main.async {
                if let messageListResponse = try? JSONDecoder().decode(MessageResponse.self, from: Data(message.utf8)){
                    self.messages = messageListResponse.messages
                    self.setSeen()
                }
                
                if let newMessageResponse = try? JSONDecoder().decode(MessageModel.self, from: Data(message.utf8))
                {
                    self.messages.append(newMessageResponse)
                    self.setSeen()
                }
                
                self.scrollToLatestMessage()
            }
        }
        
        
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.notifications = []
            self.sessions = SessionResponse(total: 0, sessions: [])
            self.selectedSession = nil
            self.messages = []
            self.newMessage = ""
            self.proxy = nil
        }
    }
    
    func resetAndReconnect() {
        disconnect()
        clear()
        swiftStomp = nil
        setupSocketConnection()
        connect()
    }

    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        print(receiptId)
    }
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        print("Error: \(briefDescription), Details: \(String(describing: fullDescription))")
    }
    
}
