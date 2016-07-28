//
//  ApplicationStateManager.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class ApplicationStateManager {
    static let sharedInstance = ApplicationStateManager()
    
    private init()  {
        self.subscribeForNotifications()
    }
    deinit {
        self.unsubscribeFromNotifications()
    }
}


private protocol NotificationsSubscription {
    func subscribeForNotifications()
    func unsubscribeFromNotifications()
}

private protocol ApplicationDelegate {
    func applicationDidEnterBackground()
    func applicationDidBecomeActive()
}

//MARK: - Notification Subscription
extension ApplicationStateManager: NotificationsSubscription {
    func subscribeForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(applicationDidEnterBackground),
                                                         name: UIApplicationDidEnterBackgroundNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(applicationDidBecomeActive),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
    }
    
    func unsubscribeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

//MARK: - Application Delegate
extension ApplicationStateManager: ApplicationDelegate {
    @objc func applicationDidEnterBackground() {
        SocketManager.sharedInstance.disconnect()
        Preferences.sharedInstance.save()
    }
    
    @objc func applicationDidBecomeActive() {
        SocketManager.sharedInstance.setNeedsConnect()
    }
}