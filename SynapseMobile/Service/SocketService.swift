//
//  SocketService.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 20.11.2024.
//

import Foundation
import SwiftUI
import SocketIO

class SocketManagerService: ObservableObject {
    static let shared = SocketManagerService() // Singleton for global access

    private let manager: SocketManager
    private var socket: SocketIOClient
    @Published var notifications: [NotificationModel] = []
    @Published var sessions: [SessionModel] = []
    
    @Published var selectedSession: SessionModel?
    @Published var messages: [MessageModel] = []
    @Published var newMessage: String = ""
    
    init() {
        // Replace with your Socket.IO server URL
        let serverURL = URL(string: "ws://localhost:3000")!
        var user: User? = nil
         
        if let session = KeychainService.instance.secureGet(forKey: "user")
        {
            user = try? JSONDecoder().decode(User.self, from: Data(session.utf8))
        }
        
    
        // Add token to headers
        manager = SocketManager(
            socketURL: serverURL,
            config: [
                .log(true), // Enable logging
               .reconnects(true),
               .reconnectAttempts(-1), // Infinite  reconnect attempts
               .reconnectWait(5), // Wait 5 seconds between reconnects
            .extraHeaders(["Authorization": "Bearer \(user?.token ?? "")"]) // Add the token here
            ]
        )
           
        socket = manager.defaultSocket

        
        }

        func connect() {
            // Setup event listeners
            socket.on(clientEvent: .connect) { [weak self] data, ack in
                print("Socket connected.")
            }


            socket.on(clientEvent: .disconnect) { _, _ in
                print("Socket disconnected!")
            }

            socket.on(clientEvent: .error) { data, _ in
                print("Socket encountered an error: \(data)")
            }
            
            
            socket.on("receive_notifications"){ data, ack in
                DispatchQueue.main.async {
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data.first ?? []) else
                    {
                        print("Failed to serialize notifications data.")
                        return
                    }

                    do {
                        let notifications = try JSONDecoder().decode([NotificationModel].self, from: jsonData)
                        
                            self.notifications = notifications
                        
                    } catch {
                        print("Failed to decode notifications: \(error)")
                    }
                }
            }
            
            socket.on("receive_messages"){ data, ack in
                DispatchQueue.main.async {
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data.first ?? []) else
                    {
                        print("Failed to serialize messages data.")
                        return
                    }
                    
                    do {
                        let messages = try JSONDecoder().decode([MessageModel].self, from: jsonData)
                        self.messages = messages
                    } catch {
                        print("Failed to decode notifications: \(error)")
                    }
                }
            }
            
            socket.on("receive_sessions"){ data, ack in
                DispatchQueue.main.async {
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data.first ?? []) else
                    {
                        print("Failed to serialize sessions data.")
                        return
                    }
                    
                    do {
                        let sessions = try JSONDecoder().decode([SessionModel].self, from: jsonData)
                        self.sessions = sessions
                    } catch {
                        print("Failed to decode notifications: \(error)")
                    }
                }
            }
        
            socket.connect()
        } 
    
        func getMessages() {
            if let session = selectedSession {
                socket.emit("get_messages", ["session_id": session.id])
            }
        }

    func sendMessage(content: String, user_id: Int? = nil) {
        if let session = selectedSession {
            socket.emit("send_message", ["session_id": session.id, "content": content])
        } else {
            socket.emit("send_message", ["content": content, "participant_id": user_id!])
        }
    }

    func disconnect() {
        socket.disconnect()
    }
}

