//
//  WriteViewController.swift
//  Write
//
//  Created by Donald Hays on 10/21/15.
//
//

import Cocoa
import RealmSwift

final class WriteViewController: NSViewController, DocumentWindowViewControllerSettings, NSTextViewDelegate, NSTextStorageDelegate, TextMutationControllerDelegate {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet fileprivate dynamic var textView: NSTextView? {
        didSet {
            textView?.textStorage?.delegate = self
            textView?.typingAttributes = textAttributes
        }
    }
    
    fileprivate var writeNavigationViewController: WriteNavigationViewController? {
        didSet {
            writeNavigationViewController?.book = book
            writeNavigationViewController?.state = state
        }
    }
    
    fileprivate let textAttributes: [String: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 24
        paragraphStyle.lineSpacing = 4
        return [
            NSFontAttributeName : NSFont(name: "Georgia", size: 16)!,
            NSForegroundColorAttributeName : NSColor(white: 0.1, alpha: 1),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
    }()
    
    fileprivate lazy var textMutationController: TextMutationController = {
        let controller = TextMutationController()
        controller.delegate = self
        return controller
    }()
    
    // MARK: -
    // MARK: Internal Properties
    var supportsSecondaryContent: Bool { return true }
    var supportsScrubBar: Bool { return true }
    internal var book: Book? {
        didSet {
            writeNavigationViewController?.book = book
            
            reloadText()
        }
    }
    
    internal var state: DocumentWindowState? {
        didSet {
            writeNavigationViewController?.state = state
            
            reloadText()
        }
    }
    
    // MARK: -
    // MARK: Observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let viewController = segue.destinationController as? WriteNavigationViewController {
            writeNavigationViewController = viewController
        }
    }
    
    // MARK: -
    // MARK: Internal Static API
    internal static func instantiateFromStoryboard() -> WriteViewController {
        let storyboard = NSStoryboard(name: "Document", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "Write")
        return controller as! WriteViewController
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func reloadText() {
        guard let textView = textView else {
            return
        }
        
        guard state?.selectedIndexPath.chapter != nil && state?.selectedIndexPath.section != nil else {
            textView.string = ""
            textView.isEditable = false
            return
        }
        
        textView.isEditable = true
        
        textMutationController.reloadText()
    }
    
    fileprivate func displayError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Could not Change Text"
        alert.informativeText = "The text could not be changed at this time."
        alert.runModal()
    }
    
    // MARK: -
    // MARK: NSTextDelegate
    func textDidChange(_ notification: Notification) {
        textMutationController.scheduleTextChangeCommit()
    }
    
    // MARK: -
    // MARK: NSTextStorageDelegate
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        textStorage.setAttributes(textAttributes, range: editedRange)
    }
    
    // MARK: -
    // MARK: TextMutationControllerDelegate
    func textViewTextInTextMutationController(_ controller: TextMutationController) -> String? {
        return textView?.string
    }
    
    func paragraphsInTextMutationController(_ controller: TextMutationController) -> List<Paragraph>? {
        return sectionInTextMutationController(controller)?.textParagraphs
    }
    
    func sectionInTextMutationController(_ controller: TextMutationController) -> Section? {
        guard let book = book, let chapterIndex = state?.selectedIndexPath.chapter, let sectionIndex = state?.selectedIndexPath.section else {
            return nil
        }
        
        return book.chapters[chapterIndex].sections[sectionIndex]
    }
    
    func textMutationController(_ controller: TextMutationController, deleteTextViewCharactersInRange range: NSRange) {
        if let textView = textView, let textStorage = textView.textStorage {
            textStorage.deleteCharacters(in: range)
        }
    }
    
    func textMutationController(_ controller: TextMutationController, insertString string: String, atIndex index: Int) {
        if let textView = textView, let textStorage = textView.textStorage {
            textStorage.insert(NSAttributedString(string: string), at: index)
        }
    }
    
    func textMutationController(_ controller: TextMutationController, threwError error: NSError) {
        displayError(error)
    }
}
