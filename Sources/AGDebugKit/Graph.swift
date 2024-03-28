//
//  Graph.swift
//
//
//  Created by Kyle on 2024/1/21.
//

private import AttributeGraph
import Foundation

/// A wrapper class for AGGraph
public final class Graph {
    private unowned let graph: AGGraph?
    
    public init() {
        graph = nil
    }
    
    public init(_ pointer: UnsafeRawPointer?) {
        graph = pointer?.assumingMemoryBound(to: AGGraph.self).pointee
    }
    
    public init(bitPattern: Int) {
        graph = Unmanaged<AGGraph>.fromOpaque(.init(bitPattern: bitPattern)!).takeUnretainedValue()
    }
    
    public var dict: NSDictionary? {
        let options = ["format": "graph/dict"] as NSDictionary
        guard let description = AGGraph.description(nil, options: options) else {
            return nil
        }
        return description.takeUnretainedValue() as? NSDictionary
    }
    
    public var dot: String? {
        let options = ["format": "graph/dot"] as NSDictionary
        guard let graph,
              let description = AGGraph.description(graph, options: options)
        else {
            return nil
        }
        return description.takeUnretainedValue() as? String
    }
    
    /// Archive the current AGGraph's state to temporary directory
    ///
    /// After calling the method, you will see the following message on Xcode console:
    ///
    ///     Wrote graph data to "`$NSTemporaryDirectory()`+`name`".
    ///
    /// You can then consume the exported JSON file directly or via
    /// [GraphConverter](https://github.com/OpenSwiftUIProject/GraphConverter)
    public static func archiveGraph(name: String) {
        name.withCString { AGGraph.archiveJSON(name: $0) }
    }
    
    /// Command to transform dot file to svg
    /// 1. Install graphviz
    /// 2. Execuate `dot -Tsvg xx.dot > xx.svg`
    public static func _graphExport(_ bitPattern: Int, name: String = "aggraph_export.dot") {
        // TODO: How to get the current in memory's AGGraphStorage objects?
        // Currently we just use Xcode Memory Graph and use any of the AGGraphStorage's address
        let graph = Graph(bitPattern: bitPattern)
        let dot = graph.dot ?? ""
        let path = URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(name)")
        do {
            try dot.write(to: path, atomically: true, encoding: .utf8)
            print(#"Wrote graph data to "\#(path.absoluteString)""#)
        } catch {
            print("Error writing to file: \(error)")
        }
    }
}
