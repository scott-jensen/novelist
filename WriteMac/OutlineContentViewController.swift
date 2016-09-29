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
    func showTextActionFromOutlineContentViewController(_ outlineContentViewController: OutlineContentViewController)
}

final class OutlineContentViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet fileprivate dynamic var tableScrollView: NSScrollView?
    @IBOutlet fileprivate dynamic var tableView: NSTableView?
    @IBOutlet fileprivate dynamic var deleteButton: NSButton?
    @IBOutlet fileprivate dynamic var newSectionButton: NSButton?
    
    fileprivate var notificationToken: NotificationToken?
    fileprivate var dataController: OutlineContentDataController?
    
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
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        finishInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        finishInit()
    }
    
    fileprivate func finishInit() {
        addObserver(self, forKeyPath: "state.selectedIndexPath", options: [], context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "state.selectedIndexPath")
    }
    
    // MARK: -
    // MARK: Observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
        
        notificationToken?.stop()
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction fileprivate dynamic func delete(_ sender: AnyObject) {
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
    
    @IBAction fileprivate dynamic func newChapter(_ sender: AnyObject) {
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
    
    @IBAction fileprivate dynamic func newSection(_ sender: AnyObject) {
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
    
    @IBAction fileprivate dynamic func writeFromSelection(_ sender: AnyObject) {
        if state?.selectedIndexPath.section != nil {
            delegate?.showTextActionFromOutlineContentViewController(self)
        }
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func reloadData() {
        tableView?.reloadData()
        reloadSelection()
        tableScrollView?.flashScrollers()
    }
    
    fileprivate func reloadSelection() {
        guard let dataController = dataController, let tableView = tableView, let selectedIndexPath = state?.selectedIndexPath else {
            return
        }
        
        if let index = dataController.tableRowForIndexPath(selectedIndexPath) {
            deleteButton?.isEnabled = true
            newSectionButton?.isEnabled = selectedIndexPath.chapter != nil
            tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        } else {
            deleteButton?.isEnabled = false
            newSectionButton?.isEnabled = false
            tableView.deselectAll(nil)
        }
    }
    
    // MARK: -
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataController?.tableNumberOfRows ?? 0
    }
    
    // MARK: -
    // MARK: NSTableViewDelegate
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let dataController = dataController else {
            return 20
        }
        
        let representation = dataController.tableRepresentation(row)
        switch representation.rowType {
        case .chapter:
            return 55
        case .section:
            return 22
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let dataController = dataController else {
            return nil
        }
        
        let representation = dataController.tableRepresentation(row)
        let view: NSTableCellView
        switch representation.rowType {
        case .chapter:
            view = tableView.make(withIdentifier: "Chapter", owner: nil) as! NSTableCellView
            if let title = representation.title {
                view.textField?.stringValue = "Chapter \(representation.indexPath.chapter! + 1): \(title)"
            } else {
                view.textField?.stringValue = "Chapter \(representation.indexPath.chapter! + 1)"
            }
        case .section:
            view = tableView.make(withIdentifier: "Section", owner: nil) as! NSTableCellView
            if let title = representation.title {
                view.textField?.stringValue = "Section \(representation.indexPath.section! + 1): \(title)"
            } else {
                view.textField?.stringValue = "Section \(representation.indexPath.section! + 1)"
            }
        }
        
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let dataController = dataController, let state = state else {
            return
        }
        
        guard let tableViewIndex = tableView?.selectedRow , tableViewIndex != -1 else {
            state.selectedIndexPath = BookIndexPath()
            return
        }
        
        let representation = dataController.tableRepresentation(tableViewIndex)
        state.selectedIndexPath = representation.indexPath
    }
}
