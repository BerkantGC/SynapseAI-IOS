//
//  File.swift
//  Synapse AI
//
//  Created by Berkant Gürcan on 8.06.2025.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self // 🔧 ÖNEMLİ: delegate atanmazsa willPresent / didReceive çalışmaz
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni hatası: \(error)")
            } else {
                print("Bildirim izni verildi: \(granted)")
            }
        }
        
        application.registerForRemoteNotifications()
        return true
    }

    // ✅ APNs Token geldiğinde
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        print("APNs Token: \(token)")
        UserDefaults.standard.set(token, forKey: "apns_token")
    }

    // ❌ Token alınamazsa
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs kaydı başarısız: \(error.localizedDescription)")
    }

    // ✅ Bildirim foreground’da gelirse (app açıkken)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📬 Bildirim foreground'da geldi")
        completionHandler([.banner, .sound]) // 🔔 Bildirimi görünür yap
    }

    // ✅ Bildirime tıklanınca çalışır (hem background hem terminated)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("🔔 Bildirime tıklandı. Payload:", userInfo)
        
        if let fromIdAny = userInfo["from_id"] {
            let fromId = String(describing: fromIdAny)
            NotificationCenter.default.post(name: .navigateToProfile, object: fromId)
        }

        completionHandler()
    }
}


extension Notification.Name {
    static let navigateToProfile = Notification.Name("navigateToProfile")
}
