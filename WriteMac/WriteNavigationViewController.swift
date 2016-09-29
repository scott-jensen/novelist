//
//  WriteNavigationViewController.swift
//  Write
//
//  Created by Donald Hays on 11/2/15.
//
//

import Cocoa

final class WriteNavigationViewController: NSViewController {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet fileprivate dynamic var chapterPopupButton: NSPopUpButton?
    @IBOutlet fileprivate dynamic var sectionPopupButton: NSPopUpButton?
    @IBOutlet fileprivate dynamic var chapterNameTextField: NSTextField?
    @IBOutlet fileprivate dynamic var sectionNameTextField: NSTextField?
    
    // MARK: -
    // MARK: Internal Properties
    internal var book: Book?
    internal var state: DocumentWindowState?
    
    // MARK: -
    // MARK: Observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "state.selectedIndexPath" {
            reloadComboBoxes()
            reloadChapterNameTextField()
            reloadSectionNameTextField()
        }
    }
    
    // MARK: -
    // MARK: NSViewController
    override func viewDidAppear() {
        super.viewDidAppear()
        
        reloadComboBoxes()
        reloadChapterNameTextField()
        reloadSectionNameTextField()
        
        addObserver(self, forKeyPath: "state.selectedIndexPath", options: [], context: nil)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        reloadComboBoxes()
        
        removeObserver(self, forKeyPath: "state.selectedIndexPath")
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction fileprivate dynamic func goBack(_ sender: AnyObject) {
        guard let book = book, let chapterIndex = state?.selectedIndexPath.chapter, let sectionIndex = state?.selectedIndexPath.section else {
            NSBeep()
            return
        }
        
        var destinationChapterIndex = chapterIndex
        var destinationSectionIndex = sectionIndex - 1
        while destinationSectionIndex < 0 {
            destinationChapterIndex -= 1
            guard destinationChapterIndex >= 0 else {
                NSBeep()
                return
            }
            destinationSectionIndex = book.chapters[destinationChapterIndex].sections.count - 1
        }
        
        state?.selectedIndexPath = BookIndexPath(chapter: destinationChapterIndex, section: destinationSectionIndex)
    }
    
    @IBAction fileprivate dynamic func goForward(_ sender: AnyObject) {
        guard let book = book, let chapterIndex = state?.selectedIndexPath.chapter, let sectionIndex = state?.selectedIndexPath.section else {
            NSBeep()
            return
        }
        
        var destinationChapterIndex = chapterIndex
        var destinationSectionIndex = sectionIndex + 1
        while destinationSectionIndex >= book.chapters[destinationChapterIndex].sections.count {
            destinationChapterIndex += 1
            guard destinationChapterIndex < book.chapters.count else {
                NSBeep()
                return
            }
            destinationSectionIndex = 0
        }
        
        state?.selectedIndexPath = BookIndexPath(chapter: destinationChapterIndex, section: destinationSectionIndex)
    }
    
    @IBAction fileprivate dynamic func changeSelectedChapter(_ sender: AnyObject) {
        guard let state = state, let chapterPopupButton = chapterPopupButton, let book = book else {
            return
        }
        
        if chapterPopupButton.indexOfSelectedItem == 0 {
            state.selectedIndexPath = BookIndexPath()
        } else {
            let chapter = book.chapters[chapterPopupButton.indexOfSelectedItem - 1]
            if chapter.sections.count > 0 {
                state.selectedIndexPath = BookIndexPath(chapter: chapterPopupButton.indexOfSelectedItem - 1, section: 0)
            } else {
                state.selectedIndexPath = BookIndexPath(chapter: chapterPopupButton.indexOfSelectedItem - 1)
            }
        }
    }
    
    @IBAction fileprivate dynamic func changeSelectedSection(_ sender: AnyObject) {
        guard let state = state, let sectionPopupButton = sectionPopupButton, let chapterIndex = state.selectedIndexPath.chapter else {
            return
        }
        
        if sectionPopupButton.indexOfSelectedItem == 0 {
            state.selectedIndexPath = BookIndexPath(chapter: chapterIndex)
        } else {
            state.selectedIndexPath = BookIndexPath(chapter: chapterIndex, section: sectionPopupButton.indexOfSelectedItem - 1)
        }
    }
    
    @IBAction fileprivate dynamic func changeChapterTitle(_ sender: AnyObject) {
        guard let book = book, let chapterIndex = state?.selectedIndexPath.chapter else {
            return
        }
        
        let chapter = book.chapters[chapterIndex]
        
        do {
            try DataCenter.sharedCenter.realm.write {
                if let title = self.chapterNameTextField?.stringValue , title.characters.count > 0 {
                    chapter.title = title
                } else {
                    chapter.title = nil
                }
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Rename Chapter"
            alert.informativeText = "The chapter could not be renamed at this time."
            alert.runModal()
        }
    }
    
    @IBAction fileprivate dynamic func changeSectionTitle(_ sender: AnyObject) {
        guard let book = book, let chapterIndex = state?.selectedIndexPath.chapter, let sectionIndex = state?.selectedIndexPath.section else {
            return
        }
        
        let section = book.chapters[chapterIndex].sections[sectionIndex]
        
        do {
            try DataCenter.sharedCenter.realm.write {
                if let title = self.sectionNameTextField?.stringValue , title.characters.count > 0 {
                    section.title = title
                } else {
                    section.title = nil
                }
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not Rename Section"
            alert.informativeText = "The section could not be renamed at this time."
            alert.runModal()
        }
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func reloadComboBoxes() {
        guard let chapterPopupButton = chapterPopupButton, let sectionPopupButton = sectionPopupButton else {
            return
        }
        
        chapterPopupButton.removeAllItems()
        sectionPopupButton.removeAllItems()
        
        chapterPopupButton.addItem(withTitle: "---")
        sectionPopupButton.addItem(withTitle: "---")
        
        guard let book = book else {
            return
        }
        
        for (index, chapter) in book.chapters.enumerated() {
            if let title = chapter.title {
                chapterPopupButton.addItem(withTitle: "Chapter \(index + 1): \(title)")
            } else {
                chapterPopupButton.addItem(withTitle: "Chapter \(index + 1)")
            }
        }
        
        guard let chapterIndex = state?.selectedIndexPath.chapter else {
            return
        }
        
        chapterPopupButton.selectItem(at: chapterIndex + 1)
        
        let sections = book.chapters[chapterIndex].sections
        
        for (index, section) in sections.enumerated() {
            if let title = section.title {
                sectionPopupButton.addItem(withTitle: "Section \(index + 1): \(title)")
            } else {
                sectionPopupButton.addItem(withTitle: "Section \(index + 1)")
            }
        }
        
        guard let sectionIndex = state?.selectedIndexPath.section else {
            return
        }
        
        sectionPopupButton.selectItem(at: sectionIndex + 1)
    }
    
    fileprivate func reloadChapterNameTextField() {
        guard let chapterNameTextField = chapterNameTextField else {
            return
        }
        
        chapterNameTextField.stringValue = ""
        
        guard let book = book, let chapterIndex = state?.selectedIndexPath.chapter else {
            chapterNameTextField.isEnabled = false
            return
        }
        
        chapterNameTextField.isEnabled = true
        
        if let chapterName = book.chapters[chapterIndex].title {
            chapterNameTextField.stringValue = chapterName
        }
    }
    
    fileprivate func reloadSectionNameTextField() {
        guard let sectionNameTextField = sectionNameTextField else {
            return
        }
        
        sectionNameTextField.stringValue = ""
        
        guard let book = book, let chapterIndex = state?.selectedIndexPath.chapter, let sectionIndex = state?.selectedIndexPath.section else {
            sectionNameTextField.isEnabled = false
            return
        }
        
        sectionNameTextField.isEnabled = true
        
        if let sectionName = book.chapters[chapterIndex].sections[sectionIndex].title {
            sectionNameTextField.stringValue = sectionName
        }
    }
}
