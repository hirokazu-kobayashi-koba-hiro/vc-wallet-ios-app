//
//  vc_wallet_ios_appApp.swift
//  vc-wallet-ios-app
//
//  Created by 小林弘和 on 2024/09/05.
//

import SwiftUI
import SwiftData

@main
struct vc_wallet_ios_appApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
