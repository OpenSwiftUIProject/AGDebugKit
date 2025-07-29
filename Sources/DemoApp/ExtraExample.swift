//
//  ContentView.swift
//
//
//  Created by Kyle on 2024/1/21.
//

import SwiftUI
import AttributeGraph
import AGDebugKit

struct ExtraExample: View {
    @State private var count = 0
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increase") {
                count += 1
            }
            ChildView()
        }
    }
}

struct ChildView: View {
    var body: some View {
        Color.red
            .extraGraph { graph, inputs, body in
                _ = graph.value.breadthFirstSearch(options: ._1) { anyAttribute in
                    print("[makeView] Body type \(anyAttribute._bodyType)")
                    print("[makeView] Value type \(anyAttribute.valueType)")
                    return false
                }
            } makeViewListCallback: { graph, inputs, body in
                _ = graph.value.breadthFirstSearch(options: ._1) { anyAttribute in
                    print("[makeViewList] Body type \(anyAttribute._bodyType)")
                    print("[makeViewList] Value type \(anyAttribute.valueType)")
                    return false
                }
            }
    }
}
