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
    
    public func start(_ mode: UInt = 1) {
        server = debugServerStart(mode)
    }
    
    public func stop() {
        debugServerStop()
        server = nil
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
    
    /// A Bool value indicating whether the server has been started successfully
    ///
    /// To make AttributeGraph start debugServer successfully, we need to pass its internal diagnostics check.
    /// In debug mode, add a symbolic breakpoint on `_ZN2AG11DebugServer5startEj` and
    /// executable `reg write w0 1` after `os_variant_has_internal_diagnostics` call.
    public var startSuccess: Bool {
        server != nil
    }
}
