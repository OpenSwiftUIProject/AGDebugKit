//
//  SwiftUIView.swift
//  
//
//  Created by Kyle on 2024/1/18.
//

import SwiftUI
import AGDebugKit

@main
@available(macOS 11.0, *)
struct DemoApp: App {    
    var body: some Scene {
        WindowGroup {
            Text("Demo")
                .onTapGesture {
                    archiveGraph(name: "test.json")
                }
        }
    }
}
