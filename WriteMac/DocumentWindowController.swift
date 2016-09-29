//
//  DocumentWindowController.swift
//  Write
//
//  Created by Donald Hays on 10/17/15.
//
//

import Cocoa

final class DocumentWindowController: NSWindowController {
    // MARK: -
    // MARK: Private API
    fileprivate let state = DocumentWindowState()
    
    fileprivate var book: Book? {
        didSet {
            documentContentViewController.book = book
        }
    }
    
    fileprivate var documentContentViewController: DocumentWindowContentViewController {
        get {
            return contentViewController as! DocumentWindowContentViewController
        }
    }
    
    // MARK: -
    // MARK: Internal Static API
    internal static func makeWithBook(_ book: Book) -> DocumentWindowController {
        let storyboard = NSStoryboard(name: "Document", bundle: nil)
        
        let controller = storyboard.instantiateInitialController() as! DocumentWindowController
        controller.book = book
        controller.documentContentViewController.state = controller.state
        
        return controller
    }
}
