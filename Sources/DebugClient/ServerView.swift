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
    private let logger = Logger(subsystem: "org.OpenSwiftUIProject.AGDebugKit", category: "DebugServer")
    
    private var server: DebugServer?

    var enableNetwork = false

    private(set) var started: Bool = false

    var timeout: Int32 = 1

    private(set) var url: URL?

    private(set) var host = ""
    private(set) var port: UInt16 = 0
    private(set) var token = 0

    init() {}
    
    func startServer() {
        let mode: DebugServer.Mode = enableNetwork ? [.valid, .networkInterface] : [.valid]
        guard let server = DebugServer.start(mode: mode),
              let url = DebugServer.copyURL() as? URL,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            logger.error("Failed to start DebugServer")
            return
        }
        self.server = server
        self.started = true

        self.url = url
        if let host = components.host {
            self.host = host
        }
        if let port = components.port {
            self.port = UInt16(port)
        }
        if let queryItems = components.queryItems,
           let tokenItem = queryItems.first(where: { $0.name == "token" }),
           let tokenValue = tokenItem.value,
           let token = Int(tokenValue) {
            self.token = token
        }
        logger.info("Server started successfully")
    }
    
    func stopServer() {
        DebugServer.stop()
        server = nil
        started = false
        url = nil
        host = ""
        port = 0
        token = 0
        logger.info("Server stopped")
    }
    
    func runDebugSession() {
        DebugServer.run(timeout: timeout)
        logger.info("Debug session started with timeout: \(self.timeout)")
    }
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
                            serverState.stopServer()
                        } else {
                            serverState.startServer()
                        }
                    }
                }
                if serverState.started {
                    Button("Run Debug Session") {
                        serverState.runDebugSession()
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
}
