//
//  OutlineMetadataViewController.swift
//  Write
//
//  Created by Donald Hays on 10/22/15.
//
//

import Cocoa
import RealmSwift

final class OutlineMetadataViewController: NSViewController {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet fileprivate var titleTextField: NSTextField?
    @IBOutlet fileprivate var authorTextField: NSTextField?
    @IBOutlet fileprivate var wordCountTextField: NSTextField?
    fileprivate var notificationToken: NotificationToken?
    
    fileprivate lazy var wordCountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
        
        return formatter
    }()
    
    // MARK: -
    // MARK: Internal Properties
    internal var book: Book? {
        didSet {
            reloadData()
        }
    }
    
    // MARK: -
    // MARK: Observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath)
    }
    
    // MARK: -
    // MARK: NSViewController
    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBAction fileprivate dynamic func changeTitle(_ sender: NSTextField) {
        guard let baseTitle = titleTextField?.stringValue, let book = book else {
            NSBeep()
            return
        }
        
        do {
            try DataCenter.sharedCenter.realm.write { () -> Void in
                book.title = baseTitle.characters.count > 0 ? baseTitle : nil
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Rename Book"
            alert.informativeText = "The book could not be renamed at this time."
            alert.runModal()
        }
    }
    
    @IBAction fileprivate dynamic func changeAuthor(_ sender: NSTextField) {
        guard let baseAuthor = authorTextField?.stringValue, let book = book else {
            NSBeep()
            return
        }
        
        do {
            try DataCenter.sharedCenter.realm.write { () -> Void in
                book.author = baseAuthor.characters.count > 0 ? baseAuthor : nil
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Change Author"
            alert.informativeText = "The author could not be changed at this time."
            alert.runModal()
        }
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func reloadData() {
        reloadTitleTextField()
        reloadAuthorTextField()
        reloadWordCount()
    }
    
    fileprivate func reloadTitleTextField() {
        titleTextField?.stringValue = book?.title ?? ""
    }
    
    fileprivate func reloadAuthorTextField() {
        authorTextField?.stringValue = book?.author ?? ""
    }
    
    fileprivate func reloadWordCount() {
        if let wordCount = book?.wordCount {
            wordCountTextField?.stringValue = wordCountFormatter.string(from: NSNumber(value: wordCount)) ?? ""
        } else {
            wordCountTextField?.stringValue = ""
        }
    }
}
