//
//  OutlineContentDataController.swift
//  Write
//
//  Created by Donald Hays on 10/25/15.
//
//

import Cocoa

enum OutlineTableRowType {
    case chapter
    case section
}

struct OutlineTableRepresentation {
    var indexPath: BookIndexPath
    var rowType: OutlineTableRowType
    var title: String?
}

final class OutlineContentDataController: NSObject {
    // MARK: -
    // MARK: Private Properties
    fileprivate let book: Book
    
    // MARK: -
    // MARK: Internal Properties
    internal var tableNumberOfRows: Int {
        let numberOfChapters = book.chapters.count
        let numberOfSections = book.chapters.reduce(0) { $0 + $1.sections.count }
        
        return numberOfChapters + numberOfSections
    }
    
    // MARK: -
    // MARK: Lifecycle
    init(book: Book) {
        self.book = book
        
        super.init()
    }
    
    // MARK: -
    // MARK: Internal API
    internal func newChapter(_ selection: BookIndexPath) throws {
        let chapter = Chapter()
        chapter.owner = self.book
        
        try DataCenter.sharedCenter.realm.write {
            if let selectedChapterIndex = selection.chapter {
                let insertionIndex = selectedChapterIndex + 1
                self.book.chapters.insert(chapter, at: insertionIndex)
            } else {
                self.book.chapters.append(chapter)
            }
        }
    }
    
    internal func newSection(_ selection: BookIndexPath) throws {
        guard let chapterIndex = selection.chapter else {
            NSBeep()
            return
        }
        
        let chapter = book.chapters[chapterIndex]
        let section = Section()
        section.owner = chapter
        
        try DataCenter.sharedCenter.realm.write {
            if let selectedSectionIndex = selection.section {
                let insertionIndex = selectedSectionIndex + 1
                chapter.sections.insert(section, at: insertionIndex)
            } else {
                chapter.sections.append(section)
            }
        }
    }
    
    internal func deleteItem(_ selection: BookIndexPath, updateSelectionInState state: DocumentWindowState) throws {
        guard let chapterIndex = selection.chapter else {
            NSBeep()
            return
        }
        
        let chapter = book.chapters[chapterIndex]
        
        if let sectionIndex = selection.section {
            let section = chapter.sections[sectionIndex]
            
            if chapter.sections.count == 1 {
                state.selectedIndexPath = BookIndexPath(chapter: chapterIndex)
            } else if sectionIndex == chapter.sections.count - 1 {
                state.selectedIndexPath = BookIndexPath(chapter: chapterIndex, section: sectionIndex - 1)
            }
            
            try section.cascadeDeleteChildren()
            try DataCenter.sharedCenter.realm.write {
                chapter.sections.remove(objectAtIndex: sectionIndex)
                DataCenter.sharedCenter.realm.delete(section)
                chapter.updateWordCount()
            }
        } else {
            if book.chapters.count == 1 {
                state.selectedIndexPath = BookIndexPath()
            } else if chapterIndex == book.chapters.count - 1 {
                state.selectedIndexPath = BookIndexPath(chapter: chapterIndex - 1)
            }
            
            try chapter.cascadeDeleteChildren()
            try DataCenter.sharedCenter.realm.write {
                self.book.chapters.remove(objectAtIndex: chapterIndex)
                DataCenter.sharedCenter.realm.delete(chapter)
                self.book.updateWordCount()
            }
        }
    }
    
    internal func tableRepresentation(_ index: Int) -> OutlineTableRepresentation {
        var currentIndex = index
        for (chapterIndex, chapter) in book.chapters.enumerated() {
            if currentIndex == 0 {
                return OutlineTableRepresentation(indexPath: BookIndexPath(chapter: chapterIndex), rowType: .chapter, title: chapter.title)
            }
            
            currentIndex -= 1
            
            if currentIndex < chapter.sections.count {
                let section = chapter.sections[currentIndex]
                return OutlineTableRepresentation(indexPath: BookIndexPath(chapter: chapterIndex, section: currentIndex), rowType: .section, title: section.title)
            }
            
            currentIndex -= chapter.sections.count
        }
        
        fatalError("Index Out of Bounds")
    }
    
    internal func tableRowForIndexPath(_ indexPath: BookIndexPath) -> Int? {
        guard let indexPathChapter = indexPath.chapter else {
            return nil
        }
        
        var row = 0
        for (chapterIndex, chapter) in book.chapters.enumerated() {
            if chapterIndex == indexPathChapter {
                if let indexPathSection = indexPath.section {
                    assert(indexPathSection < chapter.sections.count)
                    return row + 1 + indexPathSection
                } else {
                    return row
                }
            }
            
            row += 1 + chapter.sections.count
        }
        
        fatalError("Index Out of Bounds")
    }
}
