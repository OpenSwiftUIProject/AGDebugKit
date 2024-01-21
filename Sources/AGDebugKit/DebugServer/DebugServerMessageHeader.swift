//
//  DebugServerMessageHeader.swift
//
//
//  Created by Kyle on 2024/1/22.
//

extension DebugServer {
    public struct MessageHeader: Codable {
        public var token: UInt32
        public var reserved: UInt32
        public var length: UInt32
        public var reserved2: UInt32
        public init(token: UInt32, length: UInt32) {
            self.token = token
            self.reserved = 0
            self.length = length
            self.reserved2 = 0
        }
        
        public static var size: Int { MemoryLayout<Self>.size }
    }
}
