private import AttributeGraph

/// Archive the current SwiftUI graph state to temporary directory
///
/// After calling the method, you will see the following message on Xcode console:
///
///     Wrote graph data to "`$NSTemporaryDirectory()`+`name`".
///
/// You can then consume the exported JSON file directly or via
/// [GraphConverter](https://github.com/OpenSwiftUIProject/GraphConverter)
public func archiveGraph(name: String) {
    name.withCString { graphArchiveJSON($0) }
}
