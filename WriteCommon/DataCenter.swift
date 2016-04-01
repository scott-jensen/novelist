//
//  DataCenter.swift
//  Write
//
//  Created by Donald Hays on 10/13/15.
//
//

import Foundation
import RealmSwift

public final class DataCenter: NSObject {
    // MARK: -
    // MARK: Public Static Properties
    public static let sharedCenter = DataCenter()
    
    // MARK: -
    // MARK: Public Properties
    public let realm: Realm = {
        assert(NSOperationQueue.currentQueue() == NSOperationQueue.mainQueue())
        do {
            Realm.Configuration.defaultConfiguration = Realm.Configuration(
                schemaVersion: 5,
                migrationBlock: { (migration: Migration, oldSchemaVersion: UInt64) in
                    if oldSchemaVersion < 1 {
                        migration.enumerate(Chapter.className()) { oldObject, newObject in
                            newObject!["title"] = nil
                        }
                        
                        migration.enumerate(Section.className()) { oldObject, newObject in
                            newObject!["title"] = nil
                        }
                    }
                    
                    if oldSchemaVersion < 2 {
                        migration.enumerate(Paragraph.className()) { oldObject, newObject in
                            newObject!["wordCount"] = 0
                        }
                    }
                    
                    if oldSchemaVersion < 3 {
                        migration.enumerate(Section.className()) { oldObject, newObject in
                            let oldParagraphs = oldObject!["paragraphs"] as! List<MigrationObject>
                            let newTextParagraphs = newObject!["textParagraphs"] as! List<MigrationObject>
                            
                            for paragraph in oldParagraphs {
                                let newParagraph = migration.create(Paragraph.className())
                                newParagraph["text"] = paragraph["text"]
                                
                                if oldSchemaVersion > 1 {
                                    newParagraph["wordCount"] = paragraph["wordCount"]
                                } else {
                                    newParagraph["wordCount"] = 0
                                }
                                
                                newTextParagraphs.append(newParagraph)
                            }
                        }
                        
                        migration.enumerate(Paragraph.className()) { oldObject, newObject in
                            migration.delete(newObject!)
                        }
                    }
                    
                    if oldSchemaVersion < 4 {
                        migration.enumerate(Section.className()) { oldObject, newObject in
                            newObject!["wordCount"] = 0
                        }
                        
                        migration.enumerate(Chapter.className()) { oldObject, newObject in
                            newObject!["wordCount"] = 0
                        }
                        
                        migration.enumerate(Book.className()) { oldObject, newObject in
                            newObject!["wordCount"] = 0
                        }
                    }
                })
            
            let realm = try Realm()
            
            let unownedParagraphs = realm.objects(Paragraph).filter("owner = nil")
            if unownedParagraphs.count > 0 {
                try realm.write {
                    let sections = realm.objects(Section)
                    for paragraph: Paragraph in unownedParagraphs {
                        for section: Section in sections {
                            if section.textParagraphs.indexOf(paragraph) != nil || section.noteParagraphs.indexOf(paragraph) != nil {
                                paragraph.owner = section
                                section.updateWordCount()
                                print("Added owner to paragraph")
                                break
                            }
                        }
                    }
                }
            }
            
            let unownedSections = realm.objects(Section).filter("owner = nil")
            if unownedSections.count > 0 {
                try realm.write {
                    let chapters = realm.objects(Chapter)
                    for section: Section in unownedSections {
                        for chapter: Chapter in chapters {
                            if chapter.sections.indexOf(section) != nil {
                                section.owner = chapter
                                chapter.updateWordCount()
                                print("Added owner to section")
                                break
                            }
                        }
                    }
                }
            }
            
            let unownedChapters = realm.objects(Chapter).filter("owner = nil")
            if unownedChapters.count > 0 {
                try realm.write {
                    let books = realm.objects(Book)
                    for chapter: Chapter in unownedChapters {
                        for book: Book in books {
                            if book.chapters.indexOf(chapter) != nil {
                                chapter.owner = book
                                book.updateWordCount()
                                print("Added owner to chapter")
                                break
                            }
                        }
                    }
                }
            }
            
            return realm
        } catch {
            fatalError("\(error)")
        }
    }()
    
    // MARK: -
    // MARK: Lifecycle
    private override init() {
        super.init()
    }
}
