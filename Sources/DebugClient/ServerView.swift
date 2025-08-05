//
//  ServerView.swift
//
//
//  Created by Kyle on 2024/8/6.
//

import os.log
import SwiftUI
import AttributeGraph

@Observable
final class ServerState {
    var server: DebugServer?

    var enableNetwork = false

    var started: Bool {
        server != nil
    }

    var timeout: Int32 = 1

    var url: URL?

    var host = ""
    var port: UInt16 = 0
    var token = 0

    init() {}
}

struct ServerView: View {
    private let logger = Logger(subsystem: "org.OpenSwiftUIProject.AGDebugKit", category: "DebugServer")
    
    @State private var serverState = ServerState()
    
    var body: some View {
        Form {
            Section("Server Configuration") {
                Toggle(isOn: $serverState.enableNetwork) {
                    Text("Enable Network Mode")
                }
                .disabled(serverState.started)
                HStack {
                    Stepper("Timeout: \(serverState.timeout)s", value: $serverState.timeout, in: 1...60)
                }
            }
            
            Section("Server Control") {
                HStack {
                    Text("Status: \(serverState.started ? "Running" : "Stopped")") 
                    + Text(" ⏺").foregroundStyle(serverState.started ? .green : .red)
                    
                    Spacer()
                    
                    Button(serverState.started ? "Stop Server" : "Start Server") {
                        if serverState.started {
                            stopServer()
                        } else {
                            startServer()
                        }
                    }
                }
                if serverState.started {
                    Button("Run Debug Session") {
                        runDebugSession()
                    }
                }
            }
            if serverState.started {
                Section("Server Information") {
                    if !serverState.host.isEmpty {
                        Text("Host: \(serverState.host)")
                    }
                    if serverState.port > 0 {
                        Text("Port: \(serverState.port)")
                    }
                    if serverState.token > 0 {
                        Text("Token: \(serverState.token)")
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .formStyle(.grouped)
    }
    
    private func startServer() {
        let mode: DebugServer.Mode = serverState.enableNetwork ? [.valid, .networkInterface] : [.valid]
        guard let server = DebugServer.start(mode: mode),
              let url = DebugServer.copyURL() as? URL,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            logger.error("Failed to start DebugServer")
            return
        }
        serverState.server = server

        serverState.url = url
        if let host = components.host {
            serverState.host = host
        }
        if let port = components.port {
            serverState.port = UInt16(port)
        }
        if let queryItems = components.queryItems,
           let tokenItem = queryItems.first(where: { $0.name == "token" }),
           let tokenValue = tokenItem.value,
           let token = Int(tokenValue) {
            serverState.token = token
        }
        logger.info("Server started successfully")
    }
    
    private func stopServer() {
        DebugServer.stop()
        serverState.server = nil
        serverState.url = nil
        serverState.host = ""
        serverState.port = 0
        serverState.token = 0
        logger.info("Server stopped")
    }
    
    private func runDebugSession() {
        DebugServer.run(timeout: serverState.timeout)
        logger.info("Debug session started with timeout: \(serverState.timeout)")
    }
}
