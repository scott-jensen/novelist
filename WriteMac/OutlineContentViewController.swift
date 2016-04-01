//
//  OutlineContentViewController.swift
//  Write
//
//  Created by Donald Hays on 10/23/15.
//
//

import Cocoa
import RealmSwift

protocol OutlineContentViewControllerDelegate: class {
    func showTextActionFromOutlineContentViewController(outlineContentViewController: OutlineContentViewController)
}

final class OutlineContentViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet private dynamic var tableScrollView: NSScrollView?
    @IBOutlet private dynamic var tableView: NSTableView?
    @IBOutlet private dynamic var deleteButton: NSButton?
    @IBOutlet private dynamic var newSectionButton: NSButton?
    
    private var notificationToken: NotificationToken?
    private var dataController: OutlineContentDataController?
    
    // MARK: -
    // MARK: Internal Properties
    internal var book: Book? {
        didSet {
            if let book = book {
                dataController = OutlineContentDataController(book: book)
            } else {
                dataController = nil
            }
            
            reloadData()
        }
    }
    
    internal dynamic var state: DocumentWindowState? {
        didSet {
            reloadSelection()
        }
    }
    
    internal weak var delegate: OutlineContentViewControllerDelegate?
    
    // MARK: -
    // MARK: Lifecycle
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        finishInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        finishInit()
    }
    
    private func finishInit() {
        addObserver(self, forKeyPath: "state.selectedIndexPath", options: [], context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "state.selectedIndexPath")
    }
    
    // MARK: -
    // MARK: Observing
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "state.selectedIndexPath" {
            reloadSelection()
        }
    }
    
    // MARK: -
    // MARK: NSViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        notificationToken = DataCenter.sharedCenter.realm.addNotificationBlock { [weak self] notification, realm in
            self?.reloadData()
        }
        
        reloadData()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        if let notificationToken = notificationToken {
            DataCenter.sharedCenter.realm.removeNotification(notificationToken)
        }
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction private dynamic func delete(sender: AnyObject) {
        guard let state = state else {
            return
        }
        
        do {
            try dataController?.deleteItem(state.selectedIndexPath, updateSelectionInState: state)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Delete"
            alert.informativeText = "Deletion couldn't happen at this time."
            alert.runModal()
        }
    }
    
    @IBAction private dynamic func newChapter(sender: AnyObject) {
        guard let state = state else {
            return
        }
        
        do {
            try dataController?.newChapter(state.selectedIndexPath)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Create Chapter"
            alert.informativeText = "A new chapter could not be created at this time."
            alert.runModal()
        }
    }
    
    @IBAction private dynamic func newSection(sender: AnyObject) {
        guard let state = state else {
            return
        }
        
        do {
            try dataController?.newSection(state.selectedIndexPath)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Create Section"
            alert.informativeText = "A new section could not be created at this time."
            alert.runModal()
        }
    }
    
    @IBAction private dynamic func writeFromSelection(sender: AnyObject) {
        if state?.selectedIndexPath.section != nil {
            delegate?.showTextActionFromOutlineContentViewController(self)
        }
    }
    
    // MARK: -
    // MARK: Private API
    private func reloadData() {
        tableView?.reloadData()
        reloadSelection()
        tableScrollView?.flashScrollers()
    }
    
    private func reloadSelection() {
        guard let dataController = dataController, tableView = tableView, selectedIndexPath = state?.selectedIndexPath else {
            return
        }
        
        if let index = dataController.tableRowForIndexPath(selectedIndexPath) {
            deleteButton?.enabled = true
            newSectionButton?.enabled = selectedIndexPath.chapter != nil
            tableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
        } else {
            deleteButton?.enabled = false
            newSectionButton?.enabled = false
            tableView.deselectAll(nil)
        }
    }
    
    // MARK: -
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataController?.tableNumberOfRows ?? 0
    }
    
    // MARK: -
    // MARK: NSTableViewDelegate
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let dataController = dataController else {
            return 20
        }
        
        let representation = dataController.tableRepresentation(row)
        switch representation.rowType {
        case .Chapter:
            return 55
        case .Section:
            return 22
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let dataController = dataController else {
            return nil
        }
        
        let representation = dataController.tableRepresentation(row)
        let view: NSTableCellView
        switch representation.rowType {
        case .Chapter:
            view = tableView.makeViewWithIdentifier("Chapter", owner: nil) as! NSTableCellView
            if let title = representation.title {
                view.textField?.stringValue = "Chapter \(representation.indexPath.chapter! + 1): \(title)"
            } else {
                view.textField?.stringValue = "Chapter \(representation.indexPath.chapter! + 1)"
            }
        case .Section:
            view = tableView.makeViewWithIdentifier("Section", owner: nil) as! NSTableCellView
            if let title = representation.title {
                view.textField?.stringValue = "Section \(representation.indexPath.section! + 1): \(title)"
            } else {
                view.textField?.stringValue = "Section \(representation.indexPath.section! + 1)"
            }
        }
        
        return view
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        guard let dataController = dataController, state = state else {
            return
        }
        
        guard let tableViewIndex = tableView?.selectedRow where tableViewIndex != -1 else {
            state.selectedIndexPath = BookIndexPath()
            return
        }
        
        let representation = dataController.tableRepresentation(tableViewIndex)
        state.selectedIndexPath = representation.indexPath
    }
}
