//
//  ClientView.swift
//
//
//  Created by Kyle on 2024/8/6.
//

import os.log
import SwiftUI
@_spi(Debug)
import OpenGraphShims
import AttributeGraph
import Network

@Observable
final class Client {
    typealias Command = DebugClient.Command

    private let logger = Logger(subsystem: "org.OpenSwiftUIProject.AGDebugKit", category: "DebugClient")

    let debugClient = DebugClient()

    var enableNetwork = false
    var connectionState: NWConnection.State = .cancelled {
        didSet {
            stateDidChange()
        }
    }

    var urlString = ""
    var token: UInt32 = 0
    var selectedCommand: DebugClient.Command = .graphDescription
    var commandJSON = ""

    var output = ""
    var outputDate: Date?


    func connect(to url: URL) async throws {
        guard let token = getToken(from: url) else {
            logger.error("Invalid URL or missing token")
            return
        }
        self.token = token
        let updates = debugClient.connect(to: url)
        for await state in updates {
            connectionState = state
        }
    }

    private func getToken(from url: URL) -> UInt32? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let tokenItem = queryItems.first(where: { $0.name == "token" }),
              let tokenValue = tokenItem.value,
              let token = UInt32(tokenValue)
        else {
            return nil
        }
        return token
    }

    func disconnect() {
        debugClient.disconnect()
        output = ""
        outputDate = nil
        logger.info("Disconnected from server")
    }
    
    var actionButtonTitle: String {
        switch connectionState {
        case .setup, .cancelled, .failed:
            return "Connect"
        case .preparing, .waiting:
            return "Connecting..."
        case .ready:
            return "Connected"
        default:
            return "Unknown"
        }
    }
    
    func stateDidChange() {
        switch connectionState {
        case .cancelled, .failed:
            disconnect()
        case .ready:
            logger.info("Connected to server: \(self.urlString)")
        default:
            break
        }
    }

    private func data(for jsonString: String) throws -> Data {
        guard let data = jsonString.data(using: .utf8) else {
            throw ClientError.invalidJSON
        }
        // Validate it's valid JSON
        _ = try JSONSerialization.jsonObject(with: data)
        return data
    }

    private func defaultJSON(for command: Command) -> String {
        let commandDict = ["command": command.rawValue]
        guard let data = try? JSONSerialization.data(withJSONObject: commandDict, options: .prettyPrinted),
              let jsonString = String(data: data, encoding: .utf8) else {
            return #"""
            {
                "command": " \#(command.rawValue)"
            }
            """#
        }
        return jsonString
    }

    func updateCommandJSON() {
        commandJSON = defaultJSON(for: selectedCommand)
    }

    func sendCommand() async throws {
        try await debugClient.sendMessage(token: token, data: data(for: commandJSON))
        logger.info("Sending command: \(self.commandJSON)")
    }
    
    func readResponse() async throws {
        let (_, data) = try await debugClient.receiveMessage()
        logger.info("Response received")
        // TODO: Issue for sending start/stop profile command
        guard let string = String(data: data, encoding: .utf8) else {
            logger.error("Failed to decode response data")
            return
        }
        output.append(string)
        outputDate = Date.now
        logger.info("Response: \(string)")
    }
}

enum ClientError: Error {
    case invalidJSON
}

@available(macOS 14.0, *)
struct ClientView: View {
    @State private var client = Client()
    
    private var canConnect: Bool {
        !client.urlString.isEmpty && (client.connectionState == .setup || client.connectionState == .cancelled)
    }
    
    private var canSendCommand: Bool {
        client.connectionState == .ready
    }
    
    var body: some View {
        Form {
            Section("Client Connection") {
                TextField("Server URL", text: $client.urlString)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    statusIndicator
                    Spacer()
                    Button(client.actionButtonTitle) {
                        Task {
                            guard let url = URL(string: client.urlString) else {
                                return
                            }
                            try await client.connect(to: url)
                        }
                    }
                    .disabled(!canConnect || isConnected)
                    Button("Disconnect") {
                        client.disconnect()
                    }
                    .disabled(!isConnected)
                }
            }
            
            if isConnected {
                Section("Commands") {
                    Picker(selection: $client.selectedCommand) {
                        ForEach(DebugClient.Command.allCases, id: \.self) { command in
                            Text(command.rawValue).tag(command)
                        }
                    } label: {
                        Text("Command")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: client.selectedCommand) { _, _ in
                        client.updateCommandJSON()
                    }
                    
                    TextField("Command JSON", text: $client.commandJSON, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                    
                    HStack {
                        Button("Send") {
                            Task { try await client.sendCommand() }
                        }
                        .disabled(!canSendCommand)
                        
                        Button("Read Response") {
                            Task { try await client.readResponse() }
                        }
                        .disabled(!canSendCommand)
                    }
                }
                Section {
                    ScrollView {
                        Text(client.output)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 100)
                } header: {
                    Text("Response")
                } footer: {
                    if let outputDate = client.outputDate {
                        Text("\(outputDate, format: .dateTime)")
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .formStyle(.grouped)
        .onAppear {
            client.updateCommandJSON()
        }
    }
    
    private var isConnected: Bool {
        if case .ready = client.connectionState {
            return true
        }
        return false
    }
    
    private var statusIndicator: some View {
        HStack {
            Text("Status: ")
            switch client.connectionState {
            case .setup, .cancelled:
                Text("Disconnected") + Text(" ⏺").foregroundStyle(.red)
            case .preparing, .waiting:
                Text("Connecting") + Text(" ⏺").foregroundStyle(.orange)
            case .ready:
                Text("Ready") + Text(" ⏺").foregroundStyle(.green)
            case .failed(let error):
                Text("Error: \(error.localizedDescription)") + Text(" ⏺").foregroundStyle(.red)
            @unknown default:
                Text("Unknown") + Text(" ⏺").foregroundStyle(.gray)
            }
        }
    }
}
