//
//  SwiftUIView.swift
//
//
//  Created by Kyle on 2024/1/18.
//

import SwiftUI

@main
@available(macOS 14.0, *)
struct DemoApp: App {
    init() {
        // Fixing the App Activation from: https://www.alwaysrightinstitute.com/tows
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
