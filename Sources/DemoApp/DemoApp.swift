//
//  SwiftUIView.swift
//
//
//  Created by Kyle on 2024/1/18.
//

import SwiftUI
import AGDebugKit

@main
@available(macOS 14.0, *)
struct DemoApp: App {
    init() {
        let emptyGraph = Graph()
        if let dict = emptyGraph.dict {
            print(dict)
        }
        let defaultGraph = Graph(nil)
        if let dict = defaultGraph.dict {
            print(dict)
        }
        if let dot = defaultGraph.dot {
            print(dot)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .agDebug()
        }
    }
}
