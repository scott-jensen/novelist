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
    func textViewTextInTextMutationController(_ controller: TextMutationController) -> String?
    func sectionInTextMutationController(_ controller: TextMutationController) -> Section?
    func paragraphsInTextMutationController(_ controller: TextMutationController) -> List<Paragraph>?
    
    func textMutationController(_ controller: TextMutationController, deleteTextViewCharactersInRange range: NSRange)
    func textMutationController(_ controller: TextMutationController, insertString string: String, atIndex index: Int)
    
    func textMutationController(_ controller: TextMutationController, threwError error: NSError)
}

final class TextMutationController: NSObject {
    // MARK: -
    // MARK: Private API
    fileprivate var textChangeTimer: Timer?
    
    // MARK: -
    // MARK: Internal Properties
    internal weak var delegate: TextMutationControllerDelegate?
    
    // MARK: -
    // MARK: Lifecycle
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(NSApplicationDelegate.applicationWillTerminate(_:)), name: NSNotification.Name.NSApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TextMutationController.selectedIndexPathWillChange(_:)), name: NSNotification.Name(rawValue: DocumentWindowStateSelectedIndexPathWillChangeNotification), object: nil)
    }
    
    deinit {
        commitTextChangeIfScheduled()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSApplicationWillTerminate, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DocumentWindowStateSelectedIndexPathWillChangeNotification), object: nil)
    }
    
    // MARK: -
    // MARK: Timers
    fileprivate dynamic func textChangeTimerElapsed(_ timer: Timer) {
        textChangeTimer = nil
        commitTextChange()
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func commitTextChange() {
        textChangeTimer?.invalidate()
        textChangeTimer = nil
        
        guard let delegate = delegate else {
            return
        }
        
        guard let textViewText = delegate.textViewTextInTextMutationController(self), let section = delegate.sectionInTextMutationController(self) else {
            return
        }
        
        let textViewParagraphs = textViewText.components(separatedBy: "\n")
        
        do {
            try DataCenter.sharedCenter.realm.write {
                guard let realmParagraphs = delegate.paragraphsInTextMutationController(self) else {
                    return
                }
                
                let realmParagraphsText = Array(realmParagraphs.map { $0.text })
                let mutations = diff(source: realmParagraphsText, destination: textViewParagraphs)
                
                var head = 0
                var sectionShouldUpdateWordCount = false
                for mutation in mutations {
                    switch mutation {
                    case .keep:
                        head += 1
                    case .delete:
                        let paragraph = realmParagraphs[head]
                        realmParagraphs.remove(objectAtIndex: head)
                        DataCenter.sharedCenter.realm.delete(paragraph)
                        sectionShouldUpdateWordCount = true
                    case .insert(let newText):
                        let paragraph = Paragraph()
                        paragraph.owner = section
                        paragraph.text = newText
                        paragraph.wordCount = paragraph.text.wordCount
                        DataCenter.sharedCenter.realm.add(paragraph)
                        realmParagraphs.insert(paragraph, at: head)
                        sectionShouldUpdateWordCount = true
                        head += 1
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
            textChangeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TextMutationController.textChangeTimerElapsed(_:)), userInfo: nil, repeats: false)
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
        
        let newLines = Array(realmParagraphs.map { $0.text })
        let oldLines = (textViewText.length > 0 ? textViewText.components(separatedBy: "\n") : [])
        
        let mutations = diff(source: oldLines, destination: newLines)
        var oldLineHead = 0
        var rangeStart = 0
        for mutation in mutations {
            switch mutation {
            case .keep:
                rangeStart += oldLines[oldLineHead].characters.count + 1
                oldLineHead += 1
            case .delete:
                let start = rangeStart
                let length = min(textViewText.length - rangeStart, oldLines[oldLineHead].characters.count + 1)
                let range = NSRange(location: start, length: length)
                delegate.textMutationController(self, deleteTextViewCharactersInRange: range)
                textViewText.deleteCharacters(in: range)
                
                oldLineHead += 1
            case .insert(let value):
                let string = (rangeStart == 0 ? value : "\n\(value)")
                delegate.textMutationController(self, insertString: string, atIndex: rangeStart)
                textViewText.insert(string, at: rangeStart)
                rangeStart += string.utf16.count
            }
        }
    }
    
    // MARK: -
    // MARK: Notifications
    fileprivate dynamic func applicationWillTerminate(_ notification: Notification) {
        commitTextChangeIfScheduled()
    }
    
    fileprivate dynamic func selectedIndexPathWillChange(_ notification: Notification) {
        commitTextChangeIfScheduled()
    }
}
