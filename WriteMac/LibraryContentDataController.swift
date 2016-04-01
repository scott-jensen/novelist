//
//  LibraryContentDataController.swift
//  Write
//
//  Created by Donald Hays on 10/15/15.
//
//

import Cocoa
import RealmSwift

@objc protocol LibraryContentDataControllerDelegate {
    func libraryContentDataControllerDidChangeBooks(controller: LibraryContentDataController)
    func libraryContentDataControllerDidChangeSelectedBook(controller: LibraryContentDataController)
}

final class LibraryContentDataController: NSObject {
    // MARK: -
    // MARK: Private Properties
    private var realm: Realm {
        return DataCenter.sharedCenter.realm
    }
    
    // MARK: -
    // MARK: Internal Properties
    private(set) internal var books = [Book]() {
        didSet {
            delegate?.libraryContentDataControllerDidChangeBooks(self)
        }
    }
    
    internal var selectedBook: Book? {
        get {
            if let index = indexOfSelectedBook {
                return books[index]
            } else {
                return nil
            }
        } set {
            if let book = newValue {
                indexOfSelectedBook = books.indexOf { $0 == book }
            } else {
                indexOfSelectedBook = nil
            }
        }
    }
    
    internal var indexOfSelectedBook: Int? {
        didSet {
            delegate?.libraryContentDataControllerDidChangeSelectedBook(self)
        }
    }
    
    internal weak var delegate: LibraryContentDataControllerDelegate?
    
    // MARK: -
    // MARK: Lifecycle
    override init() {
        super.init()
        
        reloadData()
    }
    
    // MARK: -
    // MARK: Private API
    private func reloadData() {
        let newBooks = Array(realm.objects(Book).sorted("title"))
        if newBooks != books {
            books = newBooks
        }
    }
    
    // MARK: -
    // MARK: Internal API
    internal func createBook() throws {
        let book = Book()
        book.title = "My Great Book"
        
        try realm.write {
            self.realm.add(book)
        }
        
        reloadData()
    }
    
    internal func deleteBook(book: Book) throws {
        try book.cascadeDeleteChildren()
        
        try realm.write {
            self.realm.delete(book)
        }
        
        reloadData()
    }
    
    internal func changeTitleOfBook(book: Book, to newTitle: String) throws {
        try realm.write {
            book.title = newTitle
        }
        
        reloadData()
        
        selectedBook = book
    }
}
