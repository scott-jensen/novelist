//
//  Section.swift
//  Write
//
//  Created by Donald Hays on 10/14/15.
//
//

import Foundation
import RealmSwift

public final class Section: Object {
    // MARK: -
    // MARK: Public Properties
    public dynamic var title: String?
    public dynamic var wordCount = 0
    public dynamic var owner: Chapter? = nil
    public let textParagraphs = List<Paragraph>()
    public let noteParagraphs = List<Paragraph>()
    
    // MARK: -
    // MARK: Public API
    public func cascadeDeleteChildren() throws {
        for paragraph in textParagraphs {
            try paragraph.cascadeDeleteChildren()
        }
        
        for paragraph in noteParagraphs {
            try paragraph.cascadeDeleteChildren()
        }
        
        try DataCenter.sharedCenter.realm.write {
            DataCenter.sharedCenter.realm.delete(self.textParagraphs)
            DataCenter.sharedCenter.realm.delete(self.noteParagraphs)
        }
    }
    
    public func updateWordCount() {
        wordCount = textParagraphs.reduce(0) { $0 + $1.wordCount }
        owner?.updateWordCount()
    }
}
