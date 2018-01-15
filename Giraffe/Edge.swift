//
//  Edge.swift
//  Giraffe
//
//  Created by Justin Rushing on 1/15/18.
//  Copyright © 2018 Justin Rushing. All rights reserved.
//

import Foundation

struct Edge {
    let from: Node
    let to: Node
}

extension Edge: Hashable {
    var hashValue: Int { return self.from.hashValue ^ self.to.hashValue }
    static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
}
