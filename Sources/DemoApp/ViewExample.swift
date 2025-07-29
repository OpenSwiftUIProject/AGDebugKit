//
//  ViewExample.swift
//  AGDebugKit
//
//  Created by Kyle on 2025/7/29.
//

import SwiftUI
import AttributeGraph

struct ViewExample: View {
    fileprivate var inner: Inner

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }

    struct Inner: View {
        var body: Never { fatalError() }

        static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
            let outputs = ViewExample._makeView(
                view: .init(Attribute(Child(inner: view.value))),
                inputs: inputs
            )
            return outputs
        }

        static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
            let outputs = ViewExample._makeViewList(
                view: .init(Attribute(Child(inner: view.value))),
                inputs: inputs
            )
            return outputs
        }

        static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
            let result = ViewExample._viewListCount(inputs: inputs)
            return result
        }
    }

    struct Child: Rule {
        @Attribute var inner: Inner
        var value: ViewExample { ViewExample(inner: inner) }
    }
}
