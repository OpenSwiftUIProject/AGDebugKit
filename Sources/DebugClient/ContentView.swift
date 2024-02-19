//
//  ContentView.swift
//
//
//  Created by Kyle on 2024/1/21.
//

import AGDebugKit
import os.log
import Socket
import SwiftUI

@available(macOS 14.0, *)
struct ContentView: View {
    private let logger = Logger(subsystem: "org.OpenSwiftUIProject.AGDebugKit", category: "DebugClient")
    
    @State private var started = false
    @State private var selectedMode: Mode = .local
    @State private var timeout: Int32 = 1

    @State private var host = ""
    @State private var port: UInt16 = 0
    
    @State private var socket: Socket?
    private var connectServerDisable: Bool {
        IPv4Address(rawValue: host) == nil || port == 0 || !started
    }
    
    @State private var token = 0
    private var serverIODisable: Bool {
        socket == nil || token == 0
    }
    
    @State private var selectedCommand: Command = .graphDescription
    @State private var commandLocked = false

    @State private var output = ""
    @State private var outputDate: Date?
    
    var body: some View {
        Form {
            Section {
                Text("Status: \(started.description) ") + Text("⏺").foregroundStyle(started ? .green : .red)
                HStack {
                    Button {
                        DebugServer.shared.start(selectedMode)
                        started = DebugServer.shared.startSuccess
                        if started,
                           let url = DebugServer.shared.url,
                           let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
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
                        }
                    } label: {
                        Text("Start debug server")
                    }
                    Spacer()
                    Picker(selection: $selectedMode) {
                        Text("local").tag(Mode.local)
                        Text("network").tag(Mode.network)
                    } label: {
                        Text("Mode")
                    }
                    .pickerStyle(.segmented)
                    .disabled(started)
                }
                HStack {
                    Button("Run debug server") {
                        DebugServer.shared.run(timeout: timeout)
                    }
                    Spacer()
                    Stepper("Timeout \(timeout)", value: $timeout)
                }
                
                Button("Stop debug server") {
                    DebugServer.shared.stop()
                    started = DebugServer.shared.startSuccess
                }
            }
            Section {
                TextField("Host", text: $host)
                TextField("Port", value: $port, formatter: NumberFormatter())
                Button("Connect server") {
                    Task { try await connectServer() }
                }
                .disabled(connectServerDisable)
            }
            Section {
                TextField("Token", value: $token, formatter: NumberFormatter())
                Picker(selection: $selectedCommand) {
                    ForEach(Command.allCases) { command in
                        Text(command.rawValue).tag(command)
                    }
                } label: {
                    Text("Command")
                }
                .pickerStyle(.segmented)
                .disabled(commandLocked)
                Button("Write Data") {
                    Task {
                        try await writeData()
                        commandLocked = true
                    }
                }
                .disabled(serverIODisable)
                Button("Read Data") {
                    Task {
                        try await readData()
                        commandLocked = false
                    }
                }
                .disabled(serverIODisable)
            }
            Section {
                Text(output)
                    .multilineTextAlignment(.leading)
            } footer: {
                if let outputDate {
                    Text("\(outputDate, format: .dateTime)")
                }
            }
        }
        .buttonStyle(.bordered)
        .formStyle(.grouped)
    }
    
    func connectServer() async throws {
        guard let addr = IPv4Address(rawValue: host) else {
            return
        }
        let socket = try await Socket(IPv4Protocol.tcp)
        self.socket = socket
        do {
            try await socket.connect(to: IPv4SocketAddress(address: addr, port: port))
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    
    typealias Mode = DebugServer.Mode
    typealias Header = DebugServer.MessageHeader
    typealias Command = DebugServer.Command
    
    /// "graph/description" command is the same as `Graph().dict`
    func writeData(command: Command = .graphDescription) async throws {
        guard let socket else { return }
        let command = ["command": command.rawValue]
        let commandData = try JSONSerialization.data(withJSONObject: command)
        let size = commandData.count
        
        let header = Header(token: UInt32(token), length: UInt32(size))
        let headerData = withUnsafePointer(to: header) {
            Data(bytes: UnsafeRawPointer($0), count: Header.size)
        }
        do {
            let byteCount = try await socket.write(headerData)
            logger.info("Send: \(byteCount, privacy: .public) bytes")
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
            throw error
        }
        do {
            let byteCount = try await socket.write(commandData)
            logger.info("Send: \(byteCount, privacy: .public) bytes")
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    
    func readData() async throws {
        guard let socket else { return }
        let headerData = try await socket.read(Header.size)
        
        let header = headerData.withUnsafeBytes { pointer in
            pointer.baseAddress!
                .assumingMemoryBound(to: Header.self)
                .pointee
        }
        guard header.token == token else {
            logger.error("Token mismatch: header's token-\(header.token, privacy: .public) token-\(token)")
            return
        }
        let size = header.length
        let dictionaryData = try await socket.read(Int(size))
        let dict = try JSONSerialization.jsonObject(with: dictionaryData) as? NSDictionary
        if let dict {
            let dictDescription = dict.description
            logger.info("Received: \(dictDescription)")
            output = dictDescription
            outputDate = Date.now
        }
    }
}
