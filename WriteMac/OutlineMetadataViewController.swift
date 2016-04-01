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
    @IBOutlet private var titleTextField: NSTextField?
    @IBOutlet private var authorTextField: NSTextField?
    @IBOutlet private var wordCountTextField: NSTextField?
    private var notificationToken: NotificationToken?
    
    private lazy var wordCountFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        
        formatter.numberStyle = .DecimalStyle
        
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
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
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
        
        if let notificationToken = notificationToken {
            DataCenter.sharedCenter.realm.removeNotification(notificationToken)
        }
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction private dynamic func changeTitle(sender: NSTextField) {
        guard let baseTitle = titleTextField?.stringValue, book = book else {
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
    
    @IBAction private dynamic func changeAuthor(sender: NSTextField) {
        guard let baseAuthor = authorTextField?.stringValue, book = book else {
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
    private func reloadData() {
        reloadTitleTextField()
        reloadAuthorTextField()
        reloadWordCount()
    }
    
    private func reloadTitleTextField() {
        titleTextField?.stringValue = book?.title ?? ""
    }
    
    private func reloadAuthorTextField() {
        authorTextField?.stringValue = book?.author ?? ""
    }
    
    private func reloadWordCount() {
        if let wordCount = book?.wordCount {
            wordCountTextField?.stringValue = wordCountFormatter.stringFromNumber(wordCount) ?? ""
        } else {
            wordCountTextField?.stringValue = ""
        }
    }
}
