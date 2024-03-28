//
//  DebugServerMode.swift
//
//
//  Created by Kyle on 2024/1/22.
//

extension DebugServer {
    /// The run mode of DebugServer
    ///
    public struct Mode: RawRepresentable, Hashable {
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// Localhost mode: example host is `127.0.0.1`
        public static let local = Mode(rawValue: 1)
        
        /// Network mode: example host is `192.168.8.230`
        public static let network = Mode(rawValue: 3)
    }
}
