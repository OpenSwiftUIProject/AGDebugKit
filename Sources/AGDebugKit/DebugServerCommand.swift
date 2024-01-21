//
//  DebugServerCommand.swift
//
//
//  Created by Kyle on 2024/1/22.
//

extension DebugServer {
    public enum Command: String, CaseIterable, Hashable, Identifiable {
        case graphDescription = "graph/description"
        case profilerStart = "profiler/start"
        case profilerStop = "profiler/stop"
        case profilerReset = "profiler/reset"
        case profilerMark = "profiler/mark"
        
        public var id: String { rawValue }
    }
}
