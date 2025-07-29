//
//  AGDebugModifier.swift
//
//
//  Created by Kyle on 2024/1/21.
//

import AGDebugKit
import AttributeGraph
import SwiftUI

@available(macOS 13, *)
struct AGDebugItem: Equatable, Identifiable {
    var url: URL
    var format: Format

    enum Format: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        
        case json, dot
    }

    init(name: String, format: Format) {
        url = URL(filePath: NSTemporaryDirectory().appending("\(name).\(format.rawValue)"))
        self.format = format
    }

    var id: String { url.absoluteString }
}

@available(macOS 14, *)
struct AGDebugModifier: ViewModifier {
    @State private var showInspector = false
    @State private var items: [AGDebugItem] = []

    fileprivate static var sharedGraphbitPattern: Int = 0
    @State private var format: AGDebugItem.Format = .dot

    func body(content: Content) -> some View {
        content
            .toolbar {
                Picker("Format", selection: $format) {
                    ForEach(AGDebugItem.Format.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }.pickerStyle(.segmented)
                Button {
                    let item = AGDebugItem(name: Date.now.ISO8601Format(), format: format)
                    let name = item.url.lastPathComponent
                    switch format {
                    case .json:
                        Graph.archiveGraph(name: name)
                    case .dot:
                        Graph._graphExport(AGDebugModifier.sharedGraphbitPattern, name: name)
                    }
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
            .overlay { _GraphFetcher() }
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

struct _GraphFetcher: View {
    var body: Never { fatalError("Unimplemented") }

    static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        if let current = Subgraph.current {
            let graph = current.graph
            if #available(macOS 14, *) {
                AGDebugModifier.sharedGraphbitPattern = unsafeBitCast(graph, to: Int.self)
            }
        }

        return withUnsafePointer(to: view) { pointer in
            let view = UnsafeRawPointer(pointer).assumingMemoryBound(to: _GraphValue<EmptyView>.self)
            return EmptyView._makeView(view: view.pointee, inputs: inputs)
        }
    }

    static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        withUnsafePointer(to: view) { pointer in
            let view = UnsafeRawPointer(pointer).assumingMemoryBound(to: _GraphValue<EmptyView>.self)
            return EmptyView._makeViewList(view: view.pointee, inputs: inputs)
        }
    }
}
