//
//  DocumentWindowContentViewController.swift
//  Write
//
//  Created by Donald Hays on 10/19/15.
//
//

import Cocoa

@objc protocol DocumentWindowViewControllerSettings {
    var supportsSecondaryContent: Bool { get }
    var supportsScrubBar: Bool { get }
}

final class DocumentWindowContentViewController: NSViewController, DocumentWindowTitleBarViewControllerDelegate, OutlineViewControllerDelegate {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet private var mainContentContainerView: NSView?
    @IBOutlet private var secondaryContentContainerView: NSView?
    @IBOutlet private var scrubBarContainerView: NSView?
    
    private var mainPresentedViewController: NSViewController?
    private var mainPresentedViewControllerConstraints = [NSLayoutConstraint]()
    
    private var secondaryPresentedViewController: NSViewController?
    private var secondaryPresentedViewControllerConstraints = [NSLayoutConstraint]()
    
    private var titleBarViewController: DocumentWindowTitleBarViewController?
    
    private var scrubBarViewController: ScrubBarViewController? {
        didSet {
            scrubBarViewController?.state = state
            scrubBarViewController?.book = book
        }
    }
    
    private lazy var outlineViewController: OutlineViewController = {
        let controller = OutlineViewController.instantiateFromStoryboard()
        controller.delegate = self
        return controller
    }()
    
    private lazy var writeViewController: WriteViewController = {
        let controller = WriteViewController.instantiateFromStoryboard()
        
        return controller
    }()
    
    private lazy var outlineNotesViewController: OutlineNotesViewController = {
        let controller = OutlineNotesViewController.instantiateFromStoryboard()
        
        return controller
    }()
    
    // MARK: -
    // MARK: Internal Properties
    internal var state: DocumentWindowState? {
        didSet {
            scrubBarViewController?.state = state
            outlineViewController.state = state
            writeViewController.state = state
            outlineNotesViewController.state = state
        }
    }
    
    internal var book: Book? {
        didSet {
            scrubBarViewController?.book = book
            outlineViewController.book = book
            writeViewController.book = book
            outlineNotesViewController.book = book
        }
    }
    
    // MARK: -
    // MARK: NSViewController
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let titleBarViewController = segue.destinationController as? DocumentWindowTitleBarViewController {
            self.titleBarViewController = titleBarViewController
            titleBarViewController.delegate = self
        }
        
        if let scrubBarViewController = segue.destinationController as? ScrubBarViewController {
            self.scrubBarViewController = scrubBarViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentOutline()
        presentOutlineNotes()
    }
    
    // MARK: -
    // MARK: Private API
    private func presentPrimaryViewController(viewController: NSViewController) {
        guard let settings = viewController as? DocumentWindowViewControllerSettings else {
            fatalError("Presented view controller must support settings")
        }
        
        guard let mainContentContainerView = mainContentContainerView else {
            fatalError("Must have main content container view when presenting main view")
        }
        
        secondaryContentContainerView?.hidden = !settings.supportsSecondaryContent
        scrubBarContainerView?.hidden = !settings.supportsScrubBar
        
        titleBarViewController?.secondaryContentSupported = settings.supportsSecondaryContent
        
        if let mainPresentedViewController = mainPresentedViewController {
            NSLayoutConstraint.deactivateConstraints(mainPresentedViewControllerConstraints)
            mainPresentedViewControllerConstraints = []
            mainPresentedViewController.view.removeFromSuperview()
            mainPresentedViewController.removeFromParentViewController()
            self.mainPresentedViewController = nil
        }
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(viewController)
        mainContentContainerView.addSubview(viewController.view)
        mainPresentedViewController = viewController
        mainPresentedViewControllerConstraints = [
            viewController.view.topAnchor.constraintEqualToAnchor(mainContentContainerView.topAnchor),
            viewController.view.leadingAnchor.constraintEqualToAnchor(mainContentContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraintEqualToAnchor(mainContentContainerView.trailingAnchor),
            viewController.view.bottomAnchor.constraintEqualToAnchor(mainContentContainerView.bottomAnchor)
        ]
        NSLayoutConstraint.activateConstraints(mainPresentedViewControllerConstraints)
    }
    
    private func presentSecondaryViewController(viewController: NSViewController) {
        guard let secondaryContentContainerView = secondaryContentContainerView else {
            fatalError("Must have secondary content container view when presenting secondary view")
        }
        
        if let secondaryPresentedViewController = secondaryPresentedViewController {
            NSLayoutConstraint.deactivateConstraints(secondaryPresentedViewControllerConstraints)
            secondaryPresentedViewControllerConstraints = []
            secondaryPresentedViewController.view.removeFromSuperview()
            secondaryPresentedViewController.removeFromParentViewController()
            self.secondaryPresentedViewController = nil
        }
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(viewController)
        secondaryContentContainerView.addSubview(viewController.view)
        secondaryPresentedViewController = viewController
        secondaryPresentedViewControllerConstraints = [
            viewController.view.topAnchor.constraintEqualToAnchor(secondaryContentContainerView.topAnchor),
            viewController.view.leadingAnchor.constraintEqualToAnchor(secondaryContentContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraintEqualToAnchor(secondaryContentContainerView.trailingAnchor),
            viewController.view.bottomAnchor.constraintEqualToAnchor(secondaryContentContainerView.bottomAnchor)
        ]
        NSLayoutConstraint.activateConstraints(secondaryPresentedViewControllerConstraints)
    }
    
    private func presentOutline() {
        presentPrimaryViewController(outlineViewController)
    }
    
    private func presentShowText() {
        presentPrimaryViewController(writeViewController)
    }
    
    private func presentOutlineNotes() {
        presentSecondaryViewController(outlineNotesViewController)
    }
    
    private func presentNotepad() {
        
    }
    
    // MARK: -
    // MARK: DocumentWindowTitleBarViewControllerDelegate
    func titleBarViewControllerShowOutlineAction(titleBarViewController: DocumentWindowTitleBarViewController) {
        presentOutline()
    }
    
    func titleBarViewControllerShowTextAction(titleBarViewController: DocumentWindowTitleBarViewController) {
        presentShowText()
    }
    
    func titleBarViewControllerShowOutlineNotesAction(titleBarViewController: DocumentWindowTitleBarViewController) {
        presentOutlineNotes()
    }
    
    func titleBarViewControllerShowNotepadAction(titleBarViewController: DocumentWindowTitleBarViewController) {
        presentNotepad()
    }
    
    // MARK: -
    // MARK: OutlineViewControllerDelegate
    func showTextActionForOutlineViewController(outlineViewController: OutlineViewController) {
        presentShowText()
    }
}
