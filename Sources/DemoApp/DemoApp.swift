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
    init() {
        Graph.archiveGraph(name: "init.json")
        
        let emptyGraph = Graph()
        if let dict = emptyGraph.dict {
            print(dict)
        }
        let defaultGraph = Graph(nil)
        if let dict = emptyGraph.dict {
            print(dict)
        }
        if let dot = emptyGraph.dot {
            print(dot)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Text("Demo")
                .onTapGesture {
                    Graph.archiveGraph(name: "demo.json")
                }
        }
    }
}
