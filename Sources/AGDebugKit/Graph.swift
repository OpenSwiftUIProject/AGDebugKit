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
    let graph: UnsafeRawPointer?
    
    public init() {
        graph = nil
    }
    
    public init(_ pointer: UnsafeRawPointer?) {
        graph = graphCreateShared(pointer)
    }
    
    public var dict: NSDictionary? {
        let options = ["format": "graph/dict"] as NSDictionary
        guard let description = graphDescription(options: options) else {
            return nil
        }
        return Unmanaged<NSDictionary>.fromOpaque(description).takeUnretainedValue()
    }
    
    public var dot: String? {
        let options = ["format": "graph/dot"] as NSDictionary
        guard let graph,
              let description = graphDescription(graph, options: options)
        else {
            return nil
        }
        return Unmanaged<NSString>.fromOpaque(description).takeUnretainedValue() as String
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
        name.withCString { graphArchiveJSON($0) }
    }
}
