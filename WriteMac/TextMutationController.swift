//
//  TextMutationController.swift
//  Write
//
//  Created by Donald Hays on 11/21/15.
//
//

import Cocoa
import RealmSwift

protocol TextMutationControllerDelegate: class {
    func textViewTextInTextMutationController(controller: TextMutationController) -> String?
    func sectionInTextMutationController(controller: TextMutationController) -> Section?
    func paragraphsInTextMutationController(controller: TextMutationController) -> List<Paragraph>?
    
    func textMutationController(controller: TextMutationController, deleteTextViewCharactersInRange range: NSRange)
    func textMutationController(controller: TextMutationController, insertString string: String, atIndex index: Int)
    
    func textMutationController(controller: TextMutationController, threwError error: NSError)
}

final class TextMutationController: NSObject {
    // MARK: -
    // MARK: Private API
    private var textChangeTimer: NSTimer?
    
    // MARK: -
    // MARK: Internal Properties
    internal weak var delegate: TextMutationControllerDelegate?
    
    // MARK: -
    // MARK: Lifecycle
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillTerminate:", name: NSApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedIndexPathWillChange:", name: DocumentWindowStateSelectedIndexPathWillChangeNotification, object: nil)
    }
    
    deinit {
        commitTextChangeIfScheduled()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DocumentWindowStateSelectedIndexPathWillChangeNotification, object: nil)
    }
    
    // MARK: -
    // MARK: Timers
    private dynamic func textChangeTimerElapsed(timer: NSTimer) {
        textChangeTimer = nil
        commitTextChange()
    }
    
    // MARK: -
    // MARK: Private API
    private func commitTextChange() {
        textChangeTimer?.invalidate()
        textChangeTimer = nil
        
        guard let delegate = delegate else {
            return
        }
        
        guard let textViewText = delegate.textViewTextInTextMutationController(self), section = delegate.sectionInTextMutationController(self) else {
            return
        }
        
        let textViewParagraphs = textViewText.componentsSeparatedByString("\n")
        
        do {
            try DataCenter.sharedCenter.realm.write {
                guard let realmParagraphs = delegate.paragraphsInTextMutationController(self) else {
                    return
                }
                
                let realmParagraphsText = realmParagraphs.map { $0.text }
                let mutations = diff(source: realmParagraphsText, destination: textViewParagraphs)
                
                var head = 0
                var sectionShouldUpdateWordCount = false
                for mutation in mutations {
                    switch mutation {
                    case .Keep:
                        head++
                    case .Delete:
                        let paragraph = realmParagraphs[head]
                        realmParagraphs.removeAtIndex(head)
                        DataCenter.sharedCenter.realm.delete(paragraph)
                        sectionShouldUpdateWordCount = true
                    case .Insert(let newText):
                        let paragraph = Paragraph()
                        paragraph.owner = section
                        paragraph.text = newText
                        paragraph.wordCount = paragraph.text.wordCount
                        DataCenter.sharedCenter.realm.add(paragraph)
                        realmParagraphs.insert(paragraph, atIndex: head)
                        sectionShouldUpdateWordCount = true
                        head++
                    }
                }
                
                if sectionShouldUpdateWordCount {
                    section.updateWordCount()
                }
            }
        } catch {
            delegate.textMutationController(self, threwError: error as NSError)
        }
    }
    
    // MARK: -
    // MARK: Internal API
    internal func scheduleTextChangeCommit() {
        if textChangeTimer == nil {
            textChangeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "textChangeTimerElapsed:", userInfo: nil, repeats: false)
        }
    }
    
    internal func commitTextChangeIfScheduled() {
        if textChangeTimer != nil {
            commitTextChange()
        }
    }
    
    internal func reloadText() {
        guard let delegate = delegate else {
            fatalError("Delegate must exist when reloadText is called")
        }
        
        guard let textViewTextImmutable = delegate.textViewTextInTextMutationController(self) else {
            return
        }
        
        let textViewText = NSMutableString(string: textViewTextImmutable)
        
        guard let realmParagraphs = delegate.paragraphsInTextMutationController(self) else {
            return
        }
        
        let newLines = realmParagraphs.map { $0.text }
        let oldLines = (textViewText.length > 0 ? textViewText.componentsSeparatedByString("\n") : [])
        
        let mutations = diff(source: oldLines, destination: newLines)
        var oldLineHead = 0
        var rangeStart = 0
        for mutation in mutations {
            switch mutation {
            case .Keep:
                rangeStart += oldLines[oldLineHead].characters.count + 1
                oldLineHead++
            case .Delete:
                let start = rangeStart
                let length = min(textViewText.length - rangeStart, oldLines[oldLineHead].characters.count + 1)
                let range = NSRange(location: start, length: length)
                delegate.textMutationController(self, deleteTextViewCharactersInRange: range)
                textViewText.deleteCharactersInRange(range)
                
                oldLineHead++
            case .Insert(let value):
                let string = (rangeStart == 0 ? value : "\n\(value)")
                delegate.textMutationController(self, insertString: string, atIndex: rangeStart)
                textViewText.insertString(string, atIndex: rangeStart)
                rangeStart += string.utf16.count
            }
        }
    }
    
    // MARK: -
    // MARK: Notifications
    private dynamic func applicationWillTerminate(notification: NSNotification) {
        commitTextChangeIfScheduled()
    }
    
    private dynamic func selectedIndexPathWillChange(notification: NSNotification) {
        commitTextChangeIfScheduled()
    }
}
