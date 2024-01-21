//
//  AGDebugModifier.swift
//
//
//  Created by Kyle on 2024/1/21.
//

import AGDebugKit
import SwiftUI

@available(macOS 13, *)
struct AGDebugItem: Equatable, Identifiable {
    var url: URL
    
    init(name: String) {
        url = URL(filePath: NSTemporaryDirectory().appending("\(name).json"))
    }
    
    var id: String { url.absoluteString }
}

@available(macOS 14, *)
struct AGDebugModifier: ViewModifier {
    @State private var showInspector = false
    @State private var items: [AGDebugItem] = []

    func body(content: Content) -> some View {
        content
            .toolbar {
                Button {
                    let item = AGDebugItem(name: Date.now.ISO8601Format())
                    Graph.archiveGraph(name: item.url.lastPathComponent)
                    items.append(item)
                } label: {
                    Image(systemName: "doc.badge.plus")
                }
                Button {
                    showInspector.toggle()
                } label: {
                    Image(systemName: "sidebar.trailing")
                }
            }
            .inspector(isPresented: $showInspector) {
                inspectorView
            }
    }
    
    private var inspectorView: some View {
        List {
            ForEach($items) { $item in
                VStack(alignment: .leading) {
                    Text(item.url.lastPathComponent)
                    Text(item.url.absoluteString)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contextMenu {
                    Button {
                        openAction(item.url)
                    } label: {
                        Text("Open")
                    }
                    Button {
                        moveAction(item.url)
                    } label: {
                        Text("Move")
                    }
                    Button(role: .destructive) {
                        try? deleteAction(item.url)
                    } label: {
                        Text("Delete")
                    }
                }
                .fileMover(isPresented: $moving, file: moveURL) { result in
                    switch result {
                    case let .success(file):
                        item.url = file
                        print(file.absoluteString)
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    // MARK: - Open

    private func openAction(_ url: URL) {
        _ = NSWorkspace.shared.open(url)
    }
    
    // MARK: - Move
    
    @State private var moving = false
    @State private var moveURL: URL?
    private func moveAction(_ url: URL) {
        moveURL = url
        moving = true
    }
    
    // MARK: - Delete

    private func deleteAction(_ url: URL) throws {
        try FileManager.default.removeItem(at: url)
        items.removeAll { $0.url == url }
    }
}

extension View {
    @available(macOS 14, *)
    func agDebug() -> some View {
        modifier(AGDebugModifier())
    }
}
