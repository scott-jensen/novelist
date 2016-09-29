//
//  Paragraph.swift
//  Write
//
//  Created by Donald Hays on 10/14/15.
//
//

import Foundation
import RealmSwift

public final class Paragraph: Object {
    // MARK: -
    // MARK: Public Properties
    public dynamic var text = ""
    public dynamic var wordCount = 0
    public dynamic var owner: Section? = nil
    
    // MARK: -
    // MARK: Public API
    public func cascadeDeleteChildren() throws {
        
    }
}

public func == (lhs: Paragraph, rhs: Paragraph) -> Bool {
    return lhs.isEqual(rhs)
}
