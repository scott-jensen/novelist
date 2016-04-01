//
//  OutlineNotesViewController.swift
//  Write
//
//  Created by Donald Hays on 11/12/15.
//
//

import Cocoa
import RealmSwift

final class OutlineNotesViewController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate, TextMutationControllerDelegate {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet private dynamic var textView: NSTextView? {
        didSet {
            textView?.textStorage?.delegate = self
            textView?.typingAttributes = textAttributes
        }
    }
    
    private let textAttributes: [String: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 23
        paragraphStyle.lineSpacing = 4
        return [
            NSFontAttributeName : NSFont(name: "Georgia", size: 16)!,
            NSForegroundColorAttributeName : NSColor(white: 0.4, alpha: 1),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
    }()
    
    private lazy var textMutationController: TextMutationController = {
        let controller = TextMutationController()
        controller.delegate = self
        return controller
    }()
    
    // MARK: -
    // MARK: Internal Properties
    internal var book: Book? {
        didSet {
            reloadText()
        }
    }
    
    internal var state: DocumentWindowState? {
        didSet {
            reloadText()
        }
    }
    
    // MARK: -
    // MARK: Observing
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "state.selectedIndexPath" {
            reloadText()
        }
    }
    
    // MARK: -
    // MARK: NSViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        textView?.undoManager?.removeAllActions()
        
        reloadText()
        
        addObserver(self, forKeyPath: "state.selectedIndexPath", options: [], context: nil)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        textMutationController.commitTextChangeIfScheduled()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        textView?.undoManager?.removeAllActions()
        
        removeObserver(self, forKeyPath: "state.selectedIndexPath")
    }
    
    // MARK: -
    // MARK: Internal Static API
    internal static func instantiateFromStoryboard() -> OutlineNotesViewController {
        let storyboard = NSStoryboard(name: "Document", bundle: nil)
        let controller = storyboard.instantiateControllerWithIdentifier("OutlineNotes")
        return controller as! OutlineNotesViewController
    }
    
    // MARK: -
    // MARK: Private API
    private func reloadText() {
        guard let textView = textView else {
            return
        }
        
        guard state?.selectedIndexPath.chapter != nil && state?.selectedIndexPath.section != nil else {
            textView.string = ""
            textView.editable = false
            return
        }
        
        textView.editable = true
        
        textMutationController.reloadText()
    }
    
    private func displayError(error: ErrorType) {
        let alert = NSAlert()
        alert.messageText = "Could not Change Text"
        alert.informativeText = "The text could not be changed at this time."
        alert.runModal()
    }
    
    // MARK: -
    // MARK: NSTextDelegate
    func textDidChange(notification: NSNotification) {
        textMutationController.scheduleTextChangeCommit()
    }
    
    // MARK: -
    // MARK: NSTextStorageDelegate
    func textStorage(textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        textStorage.setAttributes(textAttributes, range: editedRange)
    }
    
    // MARK: -
    // MARK: TextMutationControllerDelegate
    func textViewTextInTextMutationController(controller: TextMutationController) -> String? {
        return textView?.string
    }
    
    func paragraphsInTextMutationController(controller: TextMutationController) -> List<Paragraph>? {
        return sectionInTextMutationController(controller)?.noteParagraphs
    }
    
    func sectionInTextMutationController(controller: TextMutationController) -> Section? {
        guard let book = book, chapterIndex = state?.selectedIndexPath.chapter, sectionIndex = state?.selectedIndexPath.section else {
            return nil
        }
        
        return book.chapters[chapterIndex].sections[sectionIndex]
    }
    
    func textMutationController(controller: TextMutationController, deleteTextViewCharactersInRange range: NSRange) {
        if let textView = textView, textStorage = textView.textStorage {
            textStorage.deleteCharactersInRange(range)
        }
    }
    
    func textMutationController(controller: TextMutationController, insertString string: String, atIndex index: Int) {
        if let textView = textView, textStorage = textView.textStorage {
            textStorage.insertAttributedString(NSAttributedString(string: string), atIndex: index)
        }
    }
    
    func textMutationController(controller: TextMutationController, threwError error: NSError) {
        displayError(error)
    }
}
