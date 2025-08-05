//
//  ContentView.swift
//
//
//  Created by Kyle on 2024/8/6.
//

import SwiftUI

@available(macOS 14.0, *)
struct ContentView: View {
    @State private var showServerView = false
    
    var body: some View {
        VStack {
            HStack {
                Text("AG Debug Kit")
                    .font(.title)
                
                Spacer()
                
                Toggle("Show Server", isOn: $showServerView)
            }
            .padding()
            // ClientView()
            if showServerView {
                Divider()
                ServerView()
            }
            Spacer()
            
        }
    }
}
