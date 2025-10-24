//
//  OneSignalService.swift
//  SparkTasks
//
//  Created by Lars Jansenn on 24.10.2025.
//

import Foundation
import OneSignalFramework
import Combine
import AppsFlyerLib

@MainActor
final class OneSignalService: ObservableObject {

    static let shared = OneSignalService()
    private var isInitialized = false
    private let appsFlyerId = AppsFlyerLib.shared().getAppsFlyerUID()

    private init() {}

    // MARK: - Initialize OneSignal when needed
    func initializeIfNeeded() {
        guard !isInitialized else { return }

        OneSignal.initialize("982d3c99-c7ce-40d3-8c74-1f0e48a1fb73", withLaunchOptions: nil)
        OneSignal.login(appsFlyerId)
        // Указываем, что пуши требуют разрешения пользователя
        OneSignal.Notifications.clearAll()

        isInitialized = true
        print("✅ OneSignal initialized")
    }

    // MARK: - Request permission (новый API)
        func requestPermission() {
            OneSignal.Notifications.requestPermission({ accepted in
                print("🔔 Push permission granted: \(accepted)")
            }, fallbackToSettings: true)
        }

        // MARK: - Get current OneSignal ID
        func getOneSignalID() -> String? {
            return OneSignal.User.onesignalId
        }

}
