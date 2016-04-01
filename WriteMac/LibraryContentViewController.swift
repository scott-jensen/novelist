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
    @IBOutlet private dynamic var tableView: NSTableView?
    @IBOutlet private dynamic var editBookButton: NSButton?
    @IBOutlet private dynamic var deleteBookButton: NSButton?
    
    private let dataController = LibraryContentDataController()
    private var documentWindowController: DocumentWindowController?
    
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
    @IBAction private dynamic func newBook(sender: AnyObject) {
        do {
            try dataController.createBook()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Create Book"
            alert.informativeText = "A new book could not be created at this time."
            alert.runModal()
        }
    }
    
    @IBAction private dynamic func delete(sender: AnyObject) {
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
    
    @IBAction private dynamic func editBook(sender: AnyObject) {
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
    private func reloadState() {
        editBookButton?.enabled = dataController.selectedBook != nil
        deleteBookButton?.enabled = dataController.selectedBook != nil
    }
    
    // MARK: -
    // MARK: NSMenuValidation
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.tag == MenuTags.Delete {
            return dataController.selectedBook != nil
        }
        
        return true
    }
    
    // MARK: -
    // MARK: LibraryContentDataControllerDelegate
    func libraryContentDataControllerDidChangeBooks(controller: LibraryContentDataController) {
        tableView?.reloadData()
        reloadState()
    }
    
    func libraryContentDataControllerDidChangeSelectedBook(controller: LibraryContentDataController) {
        if let index = dataController.indexOfSelectedBook {
            tableView?.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
        } else {
            tableView?.deselectAll(nil)
        }
        reloadState()
    }
    
    // MARK: -
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataController.books.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let book = dataController.books[row]
        return book.title
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        guard let book = dataController.selectedBook else {
            return
        }
        
        guard let newTitle = (object as? String)?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) where newTitle.characters.count > 0 else {
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
    func tableViewSelectionDidChange(notification: NSNotification) {
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
