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
    
    init() {
        // Replace with your Socket.IO server URL
        let serverURL = URL(string: "ws://localhost:3000")!
        
        let session = KeychainService.instance.secureGet(forKey: "user")
        
        let user = try? JSONDecoder().decode(User.self, from: Data(session!.utf8))
        
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

        func emit(event: String, with data: [String: Any]) {
            if (self.socket.status == .connected){
                socket.emit(event, data)
            }
            else {
                print("Socket is not connected. Unable to emit event.")
            }
        } 
    
        func disconnect() {
            socket.disconnect()
        }
}

