//
//  Tree.swift
//  Giraffe
//
//  Created by Justin Rushing on 1/15/18.
//  Copyright © 2018 Justin Rushing. All rights reserved.
//

import Foundation

class Graph {
    private var nodes = Set<Node>()
    private var edges = Set<Edge>()
    
    func add(dependency: Dependency) {
        let childNode = Node(name: dependency.child)
        let parentNode = Node(name: dependency.parent)
        
        self.nodes.insert(childNode)
        self.nodes.insert(parentNode)
        self.edges.insert(Edge(from: parentNode, to: childNode))
    }
    
    // Edges
    func enumerateEdges(_ block: (_ from: String, _ to: String) -> Void) {
        for edge in self.edges {
            block(edge.from.name, edge.to.name)
        }
    }
    
    // Cycles
    func detectCyclicalDependencies() -> [[Node]] {
        var cyclesToReturn = [[Node]]()
        for node in self.nodes {
            let children = self.children(of: node).value
            if children.contains(node) {
                cyclesToReturn.append(self.findChain(from: node, to: node).value)
            }
        }
        
        // Reject Permutations
        var fingerprints = Set<Set<Node>>()
        var output = [[Node]]()
        for cycle in cyclesToReturn {
            let fingerprint = Set(cycle)
            if !fingerprints.contains(fingerprint) {
                fingerprints.insert(fingerprint)
                output.append(cycle)
            }
        }
        
        return output
    }
    
    // MARK - Chain Finding
    func findChain(from: String, to: String) -> [String] {
        let fromNode = Node(name: from)
        let toNode = Node(name: to)
        return findChain(from: fromNode, to: toNode).value.map { $0.name }
    }

    private func findChain(from: Node, to: Node, visitedNodes: Set<Node> = []) -> RecursiveResult<[Node]> {
        guard self.children(of: from).value.contains(to) else {
            return RecursiveResult(value: [], visitedNodes: visitedNodes)
        }
        
        guard !visitedNodes.contains(from) else {
            return RecursiveResult(value: [], visitedNodes: visitedNodes)
        }
        
        var newVisitedNodes = visitedNodes.union([from])
        
        for node in self.immediateChildren(of: from) {
            if self.children(of: node).value.contains(to) {
                let chain = self.findChain(from: node, to: to, visitedNodes: newVisitedNodes)
                newVisitedNodes.formUnion(chain.visitedNodes)
                return RecursiveResult(value: [from] + chain.value, visitedNodes: newVisitedNodes)
            }
        }
        
        return RecursiveResult(value: [from, to], visitedNodes: newVisitedNodes)
    }
    
    // MARK - Child Detection
    func children(of name: String) -> [String] {
        let node = Node(name: name)
        return self.children(of: node).value.map { $0.name }
    }
    
    private func children(of node: Node, exclusionList: Set<Node> = []) -> RecursiveResult<Set<Node>> {
        // Grab all nodes pointing to <node>
        let immediateChildren = self.immediateChildren(of: node)
        // Remove things from the exclusion list
        let newChildren = immediateChildren.subtracting(exclusionList)

        var childrenToReturn = newChildren
        var newExclusionList = exclusionList
        for child in newChildren {
            newExclusionList.formUnion(childrenToReturn)
            let result = self.children(of: child, exclusionList: childrenToReturn.union(exclusionList))
            childrenToReturn.formUnion(result.value)
            newExclusionList.formUnion(result.visitedNodes)
            newExclusionList.formUnion(childrenToReturn)
        }
        
        return RecursiveResult(value: childrenToReturn, visitedNodes: newExclusionList)

    }
    
    private func immediateChildren(of node: Node) -> Set<Node> {
        return Set(self.edges.filter { $0.from == node }.map { $0.to })
    }
    
    // MARK - Parent Detection
    func parents(of name: String) -> [String] {
        let node = Node(name: name)
        return self.parents(of: node).value.map { $0.name }
    }
    
    private func parents(of node: Node, exclusionList: Set<Node> = []) -> RecursiveResult<Set<Node>> {
        // Grab all nodes pointing to <node>
        let immediateParents = self.immediateParents(of: node)
        // Remove things from the exclusion list
        let newParents = immediateParents.subtracting(exclusionList)
        
        var parentsToReturn = newParents
        var newExclusionList = exclusionList
        for parent in newParents {
            newExclusionList.formUnion(parentsToReturn)
            let result = self.parents(of: parent, exclusionList: parentsToReturn.union(exclusionList))
            parentsToReturn.formUnion(result.value)
            newExclusionList.formUnion(result.visitedNodes)
            newExclusionList.formUnion(parentsToReturn)
        }
        
        return RecursiveResult(value: parentsToReturn, visitedNodes: newExclusionList)
        
    }

    
    private func immediateParents(of node: Node) -> Set<Node> {
        return Set(self.edges.filter { $0.to == node }.map { $0.from })
    }
    
}

// MARK: - Helper Structs
fileprivate struct RecursiveResult<T> {
    let value: T
    let visitedNodes: Set<Node>
}

// DOT Display
extension Graph {
    func generateDotFile() -> String {
        var string = "digraph {\n"
        self.enumerateEdges { (from, to) in
            string.append("\t\"\(from)\" -> \"\(to)\"\n")
        }
        string.append("}")
        return string
    }
}
