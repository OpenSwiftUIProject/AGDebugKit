//
//  DebugServer.swift
//  
//
//  Created by Kyle on 2024/1/21.
//

private import AttributeGraph
import Foundation

public final class DebugServer {
    private var server: AGDebugServer?
    
    public static let shared = DebugServer()
    
    public func start(_ mode: Mode = .local) {
        server = AGDebugServer.start(mode: mode.rawValue)
    }
    
    public func stop() {
        AGDebugServer.stop()
        server = nil
    }
    
    public func run(timeout: Int32) {
        guard let _ = server else { return }
        AGDebugServer.run(timeout: timeout)
    }
    
    public var url: URL? {
        guard let _ = server,
              let url = AGDebugServer.copyURL()
        else { return nil }
        return url as URL
    }
    
    /// A Bool value indicating whether the server has been started successfully
    ///
    /// To make AttributeGraph start debugServer successfully, we need to pass its internal diagnostics check.
    /// In debug mode, add a symbolic breakpoint on `_ZN2AG11DebugServer5startEj`, run `start(_:)` and
    /// executable `reg write w0 1` after `os_variant_has_internal_diagnostics` call.
    public var startSuccess: Bool {
        server != nil
    }
}
