//
//  GraphDebug.swift
//
//
//  Created by Kyle on 2024/1/21.
//

public import AttributeGraph
import Foundation

extension Graph {
    public var dict: [String: Any]? {
        let options = [
            Graph.descriptionFormat: Graph.descriptionFormatDictionary
        ] as NSDictionary
        guard let description = Graph.description(nil, options: options) else {
            return nil
        }
        guard let dictionary = description as? NSDictionary else {
            return nil
        }
        return dictionary as? [String: Any]
    }

    // style:
    // - bold: empty input/output edge
    // - dashed: indirect or has no value
    // color:
    // - red: is_changed
    public var dot: String? {
        let options = [
            Graph.descriptionFormat: Graph.descriptionFormatDot
        ] as NSDictionary
        guard let description = Graph.description(self, options: options)
        else {
            return nil
        }
        return description as? String
    }
}
