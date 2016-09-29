//
//  DocumentWindowState.swift
//  Write
//
//  Created by Donald Hays on 10/25/15.
//
//

import Cocoa

let DocumentWindowStateSelectedIndexPathWillChangeNotification = "DocumentWindowStateSelectedIndexPathWillChangeNotification"

struct BookIndexPath: Equatable {
    var chapter: Int?
    var section: Int?
    
    init() {
        
    }
    
    init(chapter: Int) {
        self.chapter = chapter
    }
    
    init(chapter: Int, section: Int) {
        self.chapter = chapter
        self.section = section
    }
}

func == (lhs: BookIndexPath, rhs: BookIndexPath) -> Bool {
    return lhs.chapter == rhs.chapter && lhs.section == rhs.section
}

final class DocumentWindowState: NSObject {
    var selectedIndexPath = BookIndexPath() {
        willSet {
            if selectedIndexPath != newValue {
                NotificationCenter.default.post(name: Notification.Name(rawValue: DocumentWindowStateSelectedIndexPathWillChangeNotification), object: self)
                willChangeValue(forKey: "selectedIndexPath")
            }
        } didSet {
            if oldValue != selectedIndexPath {
                didChangeValue(forKey: "selectedIndexPath")
            }
        }
    }
}
