//
//  Chapter.swift
//  Write
//
//  Created by Donald Hays on 10/14/15.
//
//

import Foundation
import RealmSwift

public final class Chapter: Object {
    // MARK: -
    // MARK: Public Properties
    public dynamic var title: String?
    public dynamic var wordCount = 0
    public dynamic var owner: Book? = nil
    public let sections = List<Section>()
    
    // MARK: -
    // MARK: Public API
    public func cascadeDeleteChildren() throws {
        for section in sections {
            try section.cascadeDeleteChildren()
        }
        
        try DataCenter.sharedCenter.realm.write {
            DataCenter.sharedCenter.realm.delete(self.sections)
        }
    }
    
    public func updateWordCount() {
        wordCount = sections.reduce(0) { $0 + $1.wordCount }
        owner?.updateWordCount()
    }
}
