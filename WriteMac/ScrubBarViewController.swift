//
//  ScrubBarViewController.swift
//  Write
//
//  Created by Donald Hays on 11/30/15.
//
//

import Cocoa

final class ScrubBarViewController: NSViewController {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet private dynamic var scrubBarView: ScrubBarView? {
        didSet {
            scrubBarView?.state = state
            scrubBarView?.book = book
        }
    }
    
    // MARK: -
    // MARK: Internal Properties
    internal var state: DocumentWindowState? {
        didSet {
            scrubBarView?.state = state
        }
    }
    
    internal var book: Book? {
        didSet {
            scrubBarView?.book = book
        }
    }
}
