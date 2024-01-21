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
    @State private var timeout = 1

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
    
    var body: some View {
        Form {
            Section {
                Text("Status: \(started.description) ") + Text("⏺").foregroundStyle(started ? .green : .red)
                Button {
                    DebugServer.shared.start()
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
                Button("Run debug server") {
                    DebugServer.shared.run(timeout: timeout)
                }
                Stepper("Timeout \(timeout)", value: $timeout)
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
                Button("Write Data") {
                    Task { try await writeData() }
                }
                .disabled(serverIODisable)
                Button("Read Data") {
                    Task { try await readData() }
                }
                .disabled(serverIODisable)
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
    
    struct DebugServerMessageHeader: Codable {
        var token: UInt32
        var unknown: UInt32
        var length: UInt32
        var unknown2: UInt32
        init(token: UInt32, length: UInt32) {
            self.token = token
            self.unknown = 0
            self.length = length
            self.unknown2 = 0
        }
        
        static var size: Int { MemoryLayout<Self>.size }
    }
    
    /// "graph/description" command is the same as `Graph().dict`
    func writeData(command: String = "graph/description") async throws {
        guard let socket else { return }
        let command = ["command": command]
        let commandData = try JSONSerialization.data(withJSONObject: command)
        let size = commandData.count
        
        let header = DebugServerMessageHeader(token: UInt32(token), length: UInt32(size))
        let headerData = withUnsafePointer(to: header) {
            Data(bytes: UnsafeRawPointer($0), count: DebugServerMessageHeader.size)
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
        let headerData = try await socket.read(DebugServerMessageHeader.size)
        
        let header = headerData.withUnsafeBytes { pointer in
            pointer.baseAddress!
                .assumingMemoryBound(to: DebugServerMessageHeader.self)
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
            print(dict)
        }
    }
}
