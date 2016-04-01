//
//  Book.swift
//  Write
//
//  Created by Donald Hays on 10/14/15.
//
//

import Foundation
import RealmSwift

public final class Book: Object {
    // MARK: -
    // MARK: Public Properties
    public dynamic var title: String?
    public dynamic var wordCount = 0
    public dynamic var author: String?
    public let chapters = List<Chapter>()
    
    // MARK: -
    // MARK: Public API
    public func cascadeDeleteChildren() throws {
        for chapter in chapters {
            try chapter.cascadeDeleteChildren()
        }
        
        try DataCenter.sharedCenter.realm.write {
            DataCenter.sharedCenter.realm.delete(self.chapters)
        }
    }
    
    public func updateWordCount() {
        wordCount = chapters.reduce(0) { $0 + $1.wordCount }
    }
}
