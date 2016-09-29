//
//  OutlineViewController.swift
//  Write
//
//  Created by Donald Hays on 10/19/15.
//
//

import Cocoa

protocol OutlineViewControllerDelegate: class {
    func showTextActionForOutlineViewController(_ outlineViewController: OutlineViewController)
}

final class OutlineViewController: NSViewController, DocumentWindowViewControllerSettings, OutlineContentViewControllerDelegate {
    // MARK: -
    // MARK: Private Properties
    fileprivate var metadataViewController: OutlineMetadataViewController? {
        didSet {
            metadataViewController?.book = book
        }
    }
    
    fileprivate var contentViewController: OutlineContentViewController? {
        didSet {
            contentViewController?.book = book
        }
    }
    
    // MARK: -
    // MARK: Internal Properties
    internal var supportsSecondaryContent: Bool { return false }
    internal var supportsScrubBar: Bool { return false }
    internal var book: Book? {
        didSet {
            metadataViewController?.book = book
            contentViewController?.book = book
        }
    }
    
    internal var state: DocumentWindowState? {
        didSet {
            contentViewController?.state = state
        }
    }
    
    internal weak var delegate: OutlineViewControllerDelegate?
    
    // MARK: -
    // MARK: NSViewController
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let metadataViewController = segue.destinationController as? OutlineMetadataViewController {
            self.metadataViewController = metadataViewController
        }
        
        if let contentViewController = segue.destinationController as? OutlineContentViewController {
            self.contentViewController = contentViewController
            contentViewController.delegate = self
        }
    }
    
    // MARK: -
    // MARK: Internal Static API
    internal static func instantiateFromStoryboard() -> OutlineViewController {
        let storyboard = NSStoryboard(name: "Document", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "Outline")
        return controller as! OutlineViewController
    }
    
    // MARK: -
    // MARK: OutlineContentViewControllerDelegate
    func showTextActionFromOutlineContentViewController(_ outlineContentViewController: OutlineContentViewController) {
        delegate?.showTextActionForOutlineViewController(self)
    }
}
