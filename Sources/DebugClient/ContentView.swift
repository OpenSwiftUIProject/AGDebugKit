//
//  ContentView.swift
//
//
//  Created by Kyle on 2024/1/21.
//

import AGDebugKit
import Socket
import SwiftUI

@available(macOS 14.0, *)
struct ContentView: View {
    @State private var started = false
    @State private var timeout = 1

    @State private var address = ""
    @State private var port: UInt16 = 0
    
    @State private var socket: Socket?
    private var connectServerDisable: Bool {
        IPv4Address(rawValue: address) == nil || port == 0 || !started
    }
    
    @State private var token: Int = 0
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
                } label: {
                    Text("Start debug server")
                }
                Button("Run debug server") {
                    DebugServer.shared.run(timeout: timeout)
                }
                Stepper("Timeout \(timeout)", value: $timeout)
            }
            Section {
                TextField("Address", text: $address)
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
        guard let addr = IPv4Address(rawValue: address) else {
            return
        }
        let socket = try await Socket(IPv4Protocol.tcp)
        do {
            try await socket.connect(to: IPv4SocketAddress(address: addr, port: port))
        } catch {
            print(error.localizedDescription)
            throw error
        }
        self.socket = socket
    }
    
    func writeData() async throws {
        guard let socket else { return }
        
        let command = ["command": "graph/description"]
        let commandData = try JSONSerialization.data(withJSONObject: command)
        let size = commandData.count
        
        struct Header: Codable {
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
        }
        let header = Header(token: UInt32(token), length: UInt32(size))
        let headerData = try JSONEncoder().encode(header)
        do {
            let byteCount = try await socket.write(headerData)
            print("Send: \(byteCount) bytes")
        } catch {
            print(error.localizedDescription)
        }
        do {
            let byteCount = try await socket.write(commandData)
            print("Send: \(byteCount) bytes")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func readData() async throws {
        guard let socket else { return }
        let data = try await socket.read(16)
        let string = String(data: data, encoding: .utf8) ?? ""
        print("Received: \(string)")
    }
}
