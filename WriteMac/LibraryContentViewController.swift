//
//  LibraryContentViewController.swift
//  Write
//
//  Created by Donald Hays on 10/15/15.
//
//

import Cocoa

final class LibraryContentViewController: NSViewController, LibraryContentDataControllerDelegate, NSTableViewDataSource, NSTableViewDelegate {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet fileprivate dynamic var tableView: NSTableView?
    @IBOutlet fileprivate dynamic var editBookButton: NSButton?
    @IBOutlet fileprivate dynamic var deleteBookButton: NSButton?
    
    fileprivate let dataController = LibraryContentDataController()
    fileprivate var documentWindowController: DocumentWindowController?
    
    // MARK: -
    // MARK: NSViewController
    override func viewDidAppear() {
        super.viewDidAppear()
        
        dataController.delegate = self
        
        reloadState()
        tableView?.reloadData()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction fileprivate dynamic func newBook(_ sender: AnyObject) {
        do {
            try dataController.createBook()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Create Book"
            alert.informativeText = "A new book could not be created at this time."
            alert.runModal()
        }
    }
    
    @IBAction fileprivate dynamic func delete(_ sender: AnyObject) {
        guard let book = dataController.selectedBook else {
            NSBeep()
            return
        }
        
        do {
            try dataController.deleteBook(book)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Delete Book"
            alert.informativeText = "The book could not be deleted at this time."
            alert.runModal()
        }
    }
    
    @IBAction fileprivate dynamic func editBook(_ sender: AnyObject) {
        guard let book = dataController.selectedBook else {
            NSBeep()
            return
        }
        
        let documentWindowController = DocumentWindowController.makeWithBook(book)
        documentWindowController.showWindow(nil)
        documentWindowController.window?.makeKeyAndOrderFront(nil)
        self.documentWindowController = documentWindowController
        
        self.view.window?.orderOut(nil)
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func reloadState() {
        editBookButton?.isEnabled = dataController.selectedBook != nil
        deleteBookButton?.isEnabled = dataController.selectedBook != nil
    }
    
    // MARK: -
    // MARK: NSMenuValidation
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.tag == MenuTags.Delete {
            return dataController.selectedBook != nil
        }
        
        return true
    }
    
    // MARK: -
    // MARK: LibraryContentDataControllerDelegate
    func libraryContentDataControllerDidChangeBooks(_ controller: LibraryContentDataController) {
        tableView?.reloadData()
        reloadState()
    }
    
    func libraryContentDataControllerDidChangeSelectedBook(_ controller: LibraryContentDataController) {
        if let index = dataController.indexOfSelectedBook {
            tableView?.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        } else {
            tableView?.deselectAll(nil)
        }
        reloadState()
    }
    
    // MARK: -
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataController.books.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let book = dataController.books[row]
        return book.title
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard let book = dataController.selectedBook else {
            return
        }
        
        guard let newTitle = (object as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) , newTitle.characters.count > 0 else {
            return
        }
        
        do {
            try dataController.changeTitleOfBook(book, to: newTitle)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Rename Book"
            alert.informativeText = "The book could not be renamed at this time."
            alert.runModal()
        }
    }
    
    // MARK: -
    // MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = tableView else {
            return
        }
        
        if tableView.selectedRow == -1 {
            dataController.indexOfSelectedBook = nil
        } else {
            dataController.indexOfSelectedBook = tableView.selectedRow
        }
    }
}
