//
//  ExtraGraphModifier.swift
//  AGDebugKit
//
//  Created by Kyle on 2025/7/29.
//

public import SwiftUI
import AttributeGraph

public struct ExtraGraphModifier: ViewModifier {
    private var emptyModifier: EmptyModifier = .init()

    let makeViewCallback: (_GraphValue<Self>, _ViewInputs, @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> Void
    let makeViewListCallback: (_GraphValue<Self>, _ViewListInputs, @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> Void

    public init(makeViewCallback: @escaping (_GraphValue<Self>, _ViewInputs, @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> Void, makeViewListCallback: @escaping (_GraphValue<Self>, _ViewListInputs, @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> Void) {
        self.makeViewCallback = makeViewCallback
        self.makeViewListCallback = makeViewListCallback
    }

    public typealias Body = Never

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let outputs = EmptyModifier._makeView(
            modifier: modifier[\.emptyModifier],
            inputs: inputs,
            body: body
        )
        modifier.value.value.makeViewCallback(modifier, inputs, body)
        return outputs
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let outputs = EmptyModifier._makeViewList(
            modifier: modifier[\.emptyModifier],
            inputs: inputs,
            body: body
        )
        modifier.value.value.makeViewListCallback(modifier, inputs, body)
        return outputs
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        EmptyModifier._viewListCount(inputs: inputs, body: body)
    }
}

extension View {
    public func extraGraph(
        makeViewCallback: @escaping (_GraphValue<ExtraGraphModifier>, _ViewInputs, @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> Void,
        makeViewListCallback: @escaping (_GraphValue<ExtraGraphModifier>, _ViewListInputs, @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> Void
    ) -> some View {
        modifier(ExtraGraphModifier(
            makeViewCallback: makeViewCallback,
            makeViewListCallback: makeViewListCallback
        ))
    }
}
