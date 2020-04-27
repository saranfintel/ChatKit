//
//  GraphData.swift
//  ChatKit
//
//  Created by saran on 27/04/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation
import UIKit

struct Graph {
    var graphData: GraphData = GraphData()
}

extension Graph: Mappable {
    
    static func empty() -> Graph {
        return Graph(graphData: GraphData())
    }
    
    static func Map(_ json: JSONObject) -> Graph? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        let graphData : GraphData = (d <-> "graph_data") ?? GraphData()
        return Graph(graphData: graphData)
    }
}

struct GraphData {
    var value: Float = EMPTY_FLOAT
    var category: String = EMPTY_STRING
}

extension GraphData: Mappable {
    static func empty() -> GraphData {
        return GraphData(value: EMPTY_FLOAT, category: EMPTY_STRING)
    }
    static func Map(_ json: JSONObject) -> GraphData? {
        guard let d: JSONDictionary = Parse(json) else {
            return nil
        }
        let value = (d <-  "value") ?? EMPTY_FLOAT
        let category = (d <-  "category") ?? NULL_STRING
        return GraphData(value: value, category: category)
    }
}
