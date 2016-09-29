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
    @IBOutlet fileprivate var mainContentContainerView: NSView?
    @IBOutlet fileprivate var secondaryContentContainerView: NSView?
    @IBOutlet fileprivate var scrubBarContainerView: NSView?
    
    fileprivate var mainPresentedViewController: NSViewController?
    fileprivate var mainPresentedViewControllerConstraints = [NSLayoutConstraint]()
    
    fileprivate var secondaryPresentedViewController: NSViewController?
    fileprivate var secondaryPresentedViewControllerConstraints = [NSLayoutConstraint]()
    
    fileprivate var titleBarViewController: DocumentWindowTitleBarViewController?
    
    fileprivate var scrubBarViewController: ScrubBarViewController? {
        didSet {
            scrubBarViewController?.state = state
            scrubBarViewController?.book = book
        }
    }
    
    fileprivate lazy var outlineViewController: OutlineViewController = {
        let controller = OutlineViewController.instantiateFromStoryboard()
        controller.delegate = self
        return controller
    }()
    
    fileprivate lazy var writeViewController: WriteViewController = {
        let controller = WriteViewController.instantiateFromStoryboard()
        
        return controller
    }()
    
    fileprivate lazy var outlineNotesViewController: OutlineNotesViewController = {
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
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
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
    fileprivate func presentPrimaryViewController(_ viewController: NSViewController) {
        guard let settings = viewController as? DocumentWindowViewControllerSettings else {
            fatalError("Presented view controller must support settings")
        }
        
        guard let mainContentContainerView = mainContentContainerView else {
            fatalError("Must have main content container view when presenting main view")
        }
        
        secondaryContentContainerView?.isHidden = !settings.supportsSecondaryContent
        scrubBarContainerView?.isHidden = !settings.supportsScrubBar
        
        titleBarViewController?.secondaryContentSupported = settings.supportsSecondaryContent
        
        if let mainPresentedViewController = mainPresentedViewController {
            NSLayoutConstraint.deactivate(mainPresentedViewControllerConstraints)
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
            viewController.view.topAnchor.constraint(equalTo: mainContentContainerView.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: mainContentContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: mainContentContainerView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: mainContentContainerView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(mainPresentedViewControllerConstraints)
    }
    
    fileprivate func presentSecondaryViewController(_ viewController: NSViewController) {
        guard let secondaryContentContainerView = secondaryContentContainerView else {
            fatalError("Must have secondary content container view when presenting secondary view")
        }
        
        if let secondaryPresentedViewController = secondaryPresentedViewController {
            NSLayoutConstraint.deactivate(secondaryPresentedViewControllerConstraints)
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
            viewController.view.topAnchor.constraint(equalTo: secondaryContentContainerView.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: secondaryContentContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: secondaryContentContainerView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: secondaryContentContainerView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(secondaryPresentedViewControllerConstraints)
    }
    
    fileprivate func presentOutline() {
        presentPrimaryViewController(outlineViewController)
    }
    
    fileprivate func presentShowText() {
        presentPrimaryViewController(writeViewController)
    }
    
    fileprivate func presentOutlineNotes() {
        presentSecondaryViewController(outlineNotesViewController)
    }
    
    fileprivate func presentNotepad() {
        
    }
    
    // MARK: -
    // MARK: DocumentWindowTitleBarViewControllerDelegate
    func titleBarViewControllerShowOutlineAction(_ titleBarViewController: DocumentWindowTitleBarViewController) {
        presentOutline()
    }
    
    func titleBarViewControllerShowTextAction(_ titleBarViewController: DocumentWindowTitleBarViewController) {
        presentShowText()
    }
    
    func titleBarViewControllerShowOutlineNotesAction(_ titleBarViewController: DocumentWindowTitleBarViewController) {
        presentOutlineNotes()
    }
    
    func titleBarViewControllerShowNotepadAction(_ titleBarViewController: DocumentWindowTitleBarViewController) {
        presentNotepad()
    }
    
    // MARK: -
    // MARK: OutlineViewControllerDelegate
    func showTextActionForOutlineViewController(_ outlineViewController: OutlineViewController) {
        presentShowText()
    }
}
