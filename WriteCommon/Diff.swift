//
//  Diff.swift
//  Write
//
//  Created by Donald Hays on 11/2/15.
//
//

import Foundation

/// Describes a mutation to apply to a collection of T.
public enum DiffMutation<T> {
    /// Keep an existing value.
    case Keep
    
    /// Delete an existing value.
    case Delete
    
    /// Insert a new value.
    case Insert(value: T)
}

private func longestCommonSubsequenceTable<T where T: Equatable>(a: [T], _ b: [T]) -> [[Int]] {
    var table = [[Int]](count: a.count + 1, repeatedValue: [Int](count: b.count + 1, repeatedValue: 0))
    
    for i in 1 ..< a.count + 1 {
        for j in 1 ..< b.count + 1 {
            if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1] + 1
            } else {
                table[i][j] = max(table[i][j - 1], table[i - 1][j])
            }
        }
    }
    
    return table
}

private func diffBacktrack<T where T: Equatable>(table table: [[Int]], a: [T], b: [T], i: Int, j: Int) -> [DiffMutation<T>] {
    if i > 0 && j > 0 && a[i - 1] == b[j - 1] {
        return diffBacktrack(table: table, a: a, b: b, i: i - 1, j: j - 1) + [.Keep]
    } else if j > 0 && (i == 0 || table[i][j - 1] >= table[i - 1][j]) {
        return diffBacktrack(table: table, a: a, b: b, i: i, j: j - 1) + [.Insert(value: b[j - 1])]
    } else if i > 0 && (j == 0 || table[i][j - 1] < table[i - 1][j]) {
        return diffBacktrack(table: table, a: a, b: b, i: i - 1, j: j) + [.Delete]
    } else {
        return []
    }
}

/// Computes the difference between two arrays, and returns a list of mutations
/// that can by applied to the source list to change it into the destination
/// list.
public func diff<T where T: Equatable>(var source source: [T], var destination: [T]) -> [DiffMutation<T>] {
    var head = [DiffMutation<T>]()
    while let sourceFirst = source.first, destinationFirst = destination.first where sourceFirst == destinationFirst {
        head.append(.Keep)
        source.removeFirst()
        destination.removeFirst()
    }
    
    var tail = [DiffMutation<T>]()
    while let sourceLast = source.last, destinationLast = destination.last where sourceLast == destinationLast {
        tail.append(.Keep)
        source.removeLast()
        destination.removeLast()
    }
    
    let table = longestCommonSubsequenceTable(source, destination)
    return head + diffBacktrack(table: table, a: source, b: destination, i: source.count, j: destination.count) + tail
}
