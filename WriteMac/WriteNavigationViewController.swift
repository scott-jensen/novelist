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
    @IBOutlet private dynamic var chapterPopupButton: NSPopUpButton?
    @IBOutlet private dynamic var sectionPopupButton: NSPopUpButton?
    @IBOutlet private dynamic var chapterNameTextField: NSTextField?
    @IBOutlet private dynamic var sectionNameTextField: NSTextField?
    
    // MARK: -
    // MARK: Internal Properties
    internal var book: Book?
    internal var state: DocumentWindowState?
    
    // MARK: -
    // MARK: Observing
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
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
    @IBAction private dynamic func goBack(sender: AnyObject) {
        guard let book = book, chapterIndex = state?.selectedIndexPath.chapter, sectionIndex = state?.selectedIndexPath.section else {
            NSBeep()
            return
        }
        
        var destinationChapterIndex = chapterIndex
        var destinationSectionIndex = sectionIndex - 1
        while destinationSectionIndex < 0 {
            destinationChapterIndex--
            guard destinationChapterIndex >= 0 else {
                NSBeep()
                return
            }
            destinationSectionIndex = book.chapters[destinationChapterIndex].sections.count - 1
        }
        
        state?.selectedIndexPath = BookIndexPath(chapter: destinationChapterIndex, section: destinationSectionIndex)
    }
    
    @IBAction private dynamic func goForward(sender: AnyObject) {
        guard let book = book, chapterIndex = state?.selectedIndexPath.chapter, sectionIndex = state?.selectedIndexPath.section else {
            NSBeep()
            return
        }
        
        var destinationChapterIndex = chapterIndex
        var destinationSectionIndex = sectionIndex + 1
        while destinationSectionIndex >= book.chapters[destinationChapterIndex].sections.count {
            destinationChapterIndex++
            guard destinationChapterIndex < book.chapters.count else {
                NSBeep()
                return
            }
            destinationSectionIndex = 0
        }
        
        state?.selectedIndexPath = BookIndexPath(chapter: destinationChapterIndex, section: destinationSectionIndex)
    }
    
    @IBAction private dynamic func changeSelectedChapter(sender: AnyObject) {
        guard let state = state, chapterPopupButton = chapterPopupButton, book = book else {
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
    
    @IBAction private dynamic func changeSelectedSection(sender: AnyObject) {
        guard let state = state, sectionPopupButton = sectionPopupButton, chapterIndex = state.selectedIndexPath.chapter else {
            return
        }
        
        if sectionPopupButton.indexOfSelectedItem == 0 {
            state.selectedIndexPath = BookIndexPath(chapter: chapterIndex)
        } else {
            state.selectedIndexPath = BookIndexPath(chapter: chapterIndex, section: sectionPopupButton.indexOfSelectedItem - 1)
        }
    }
    
    @IBAction private dynamic func changeChapterTitle(sender: AnyObject) {
        guard let book = book, chapterIndex = state?.selectedIndexPath.chapter else {
            return
        }
        
        let chapter = book.chapters[chapterIndex]
        
        do {
            try DataCenter.sharedCenter.realm.write {
                if let title = self.chapterNameTextField?.stringValue where title.characters.count > 0 {
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
    
    @IBAction private dynamic func changeSectionTitle(sender: AnyObject) {
        guard let book = book, chapterIndex = state?.selectedIndexPath.chapter, sectionIndex = state?.selectedIndexPath.section else {
            return
        }
        
        let section = book.chapters[chapterIndex].sections[sectionIndex]
        
        do {
            try DataCenter.sharedCenter.realm.write {
                if let title = self.sectionNameTextField?.stringValue where title.characters.count > 0 {
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
    private func reloadComboBoxes() {
        guard let chapterPopupButton = chapterPopupButton, sectionPopupButton = sectionPopupButton else {
            return
        }
        
        chapterPopupButton.removeAllItems()
        sectionPopupButton.removeAllItems()
        
        chapterPopupButton.addItemWithTitle("---")
        sectionPopupButton.addItemWithTitle("---")
        
        guard let book = book else {
            return
        }
        
        for (index, chapter) in book.chapters.enumerate() {
            if let title = chapter.title {
                chapterPopupButton.addItemWithTitle("Chapter \(index + 1): \(title)")
            } else {
                chapterPopupButton.addItemWithTitle("Chapter \(index + 1)")
            }
        }
        
        guard let chapterIndex = state?.selectedIndexPath.chapter else {
            return
        }
        
        chapterPopupButton.selectItemAtIndex(chapterIndex + 1)
        
        let sections = book.chapters[chapterIndex].sections
        
        for (index, section) in sections.enumerate() {
            if let title = section.title {
                sectionPopupButton.addItemWithTitle("Section \(index + 1): \(title)")
            } else {
                sectionPopupButton.addItemWithTitle("Section \(index + 1)")
            }
        }
        
        guard let sectionIndex = state?.selectedIndexPath.section else {
            return
        }
        
        sectionPopupButton.selectItemAtIndex(sectionIndex + 1)
    }
    
    private func reloadChapterNameTextField() {
        guard let chapterNameTextField = chapterNameTextField else {
            return
        }
        
        chapterNameTextField.stringValue = ""
        
        guard let book = book, chapterIndex = state?.selectedIndexPath.chapter else {
            chapterNameTextField.enabled = false
            return
        }
        
        chapterNameTextField.enabled = true
        
        if let chapterName = book.chapters[chapterIndex].title {
            chapterNameTextField.stringValue = chapterName
        }
    }
    
    private func reloadSectionNameTextField() {
        guard let sectionNameTextField = sectionNameTextField else {
            return
        }
        
        sectionNameTextField.stringValue = ""
        
        guard let book = book, chapterIndex = state?.selectedIndexPath.chapter, sectionIndex = state?.selectedIndexPath.section else {
            sectionNameTextField.enabled = false
            return
        }
        
        sectionNameTextField.enabled = true
        
        if let sectionName = book.chapters[chapterIndex].sections[sectionIndex].title {
            sectionNameTextField.stringValue = sectionName
        }
    }
}
