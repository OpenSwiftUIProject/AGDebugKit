private import AttributeGraph

/// Archive the current SwiftUI graph state to `NSTemporaryDirectory()`+`name`
/// You can then consume the exported JSON file directly or via
/// [GraphConverter](https://github.com/OpenSwiftUIProject/GraphConverter)
public func archiveGraph(name: String) {
    name.withCString { graphArchiveJSON($0) }
}
