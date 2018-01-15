//
//  main.swift
//  Giraffe
//
//  Created by Justin Rushing on 1/15/18.
//  Copyright © 2018 Justin Rushing. All rights reserved.
//

import Foundation

print("Hello, World!")

let dependencies = [
    Dependency(parent: "A", child: "B"),
    Dependency(parent: "1", child: "A"),
    Dependency(parent: "2", child: "A"),
    Dependency(parent: "3", child: "B"),
    Dependency(parent: "B", child: "C"),
    Dependency(parent: "FOO", child: "BAR")
]

let graph = Graph()
dependencies.forEach { graph.add(dependency: $0) }
print("----- B -------")
print(graph.parents(of: "B"))
print("----- 1 -------")
print(graph.children(of: "1"))
print("----- Chain 1 -> B -----")
print(graph.findChain(from: "1", to: "B"))
print("----- Dot ------")
print(graph.generateDotFile())
