//
//  DebugServerTests.swift
//  
//
//  Created by Kyle on 2024/1/21.
//

import XCTest
import AGDebugKit

final class DebugServerTests: XCTestCase {
    func testExample() throws {
        let server = DebugServer.shared
        XCTAssertNil(server.url)
        server.start()
        // Need workaround internal_diagnostics check
        // breakpoint on _ZN2AG11DebugServer5startEj
//        let url = try XCTUnwrap(server.url)
//        print(url.absoluteString)
        server.stop()
    }
}
