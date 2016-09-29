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
    case keep
    
    /// Delete an existing value.
    case delete
    
    /// Insert a new value.
    case insert(value: T)
}

private func longestCommonSubsequenceTable<T>(_ a: [T], _ b: [T]) -> [[Int]] where T: Equatable {
    var table = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)
    
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

private func diffBacktrack<T>(_ table: [[Int]], a: [T], b: [T], i: Int, j: Int) -> [DiffMutation<T>] where T: Equatable {
    if i > 0 && j > 0 && a[i - 1] == b[j - 1] {
        return diffBacktrack(table, a: a, b: b, i: i - 1, j: j - 1) + [.keep]
    } else if j > 0 && (i == 0 || table[i][j - 1] >= table[i - 1][j]) {
        return diffBacktrack(table, a: a, b: b, i: i, j: j - 1) + [.insert(value: b[j - 1])]
    } else if i > 0 && (j == 0 || table[i][j - 1] < table[i - 1][j]) {
        return diffBacktrack(table, a: a, b: b, i: i - 1, j: j) + [.delete]
    } else {
        return []
    }
}

/// Computes the difference between two arrays, and returns a list of mutations
/// that can by applied to the source list to change it into the destination
/// list.
public func diff<T>(source: [T], destination: [T]) -> [DiffMutation<T>] where T: Equatable {
    var source = source, destination = destination
    var head = [DiffMutation<T>]()
    while let sourceFirst = source.first, let destinationFirst = destination.first , sourceFirst == destinationFirst {
        head.append(.keep)
        source.removeFirst()
        destination.removeFirst()
    }
    
    var tail = [DiffMutation<T>]()
    while let sourceLast = source.last, let destinationLast = destination.last , sourceLast == destinationLast {
        tail.append(.keep)
        source.removeLast()
        destination.removeLast()
    }
    
    let table = longestCommonSubsequenceTable(source, destination)
    return head + diffBacktrack(table, a: source, b: destination, i: source.count, j: destination.count) + tail
}
