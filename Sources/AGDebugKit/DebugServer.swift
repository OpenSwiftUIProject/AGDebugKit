//
//  DebugServer.swift
//  
//
//  Created by Kyle on 2024/1/21.
//

private import AttributeGraph
import Foundation

public final class DebugServer {
    private var server: UnsafeRawPointer?
    
    public static let shared = DebugServer()
    
    public func start() {
        server = debugServerStart(1)
    }
    
    public func stop() {
        debugServerStop()
    }
    
    public func run(timeout: Int) {
        guard let _ = server else { return }
        debugServerRun(timeout)
    }
    
    public var url: URL? {
        guard let _ = server,
              let url = debugServerCopyURL() as? URL
        else { return nil }
        return url
    }
}
