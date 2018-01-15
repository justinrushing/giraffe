//
//  Node.swift
//  Giraffe
//
//  Created by Justin Rushing on 1/15/18.
//  Copyright © 2018 Justin Rushing. All rights reserved.
//

import Foundation

struct Node {
    let name: String
}

extension Node: Hashable {
    var hashValue: Int { return self.name.hashValue }
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.name == rhs.name
    }
}
