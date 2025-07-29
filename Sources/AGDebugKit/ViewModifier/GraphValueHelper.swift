//
//  GraphHelper.swift
//  AGDebugKit
//
//  Created by Kyle on 2025/7/29.
//

package import SwiftUI
package import AttributeGraph

extension _GraphValue {
    package init(_ value: Attribute<Value>) {
        self = Swift.unsafeBitCast(value, to: Self.self)
    }

    package var value: Attribute<Value> {
        Swift.unsafeBitCast(self, to: Attribute<Value>.self)
    }

    package func unsafeCast<T>(to _: T.Type = T.self) -> _GraphValue<T> {
        _GraphValue<T>(value.unsafeCast(to: T.self))
    }

    package func unsafeBitCast<T>(to _: T.Type) -> _GraphValue<T> {
        _GraphValue<T>(value.unsafeBitCast(to: T.self))
    }
}

extension Attribute {
    package func unsafeBitCast<T>(to _: T.Type) -> Attribute<T> {
        unsafeOffset(at: 0, as: T.self)
    }
}
