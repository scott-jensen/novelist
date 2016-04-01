//
//  DocumentWindowTitleBarViewController.swift
//  Write
//
//  Created by Donald Hays on 10/18/15.
//
//

import Cocoa

@objc protocol DocumentWindowTitleBarViewControllerDelegate {
    func titleBarViewControllerShowOutlineAction(titleBarViewController: DocumentWindowTitleBarViewController)
    func titleBarViewControllerShowTextAction(titleBarViewController: DocumentWindowTitleBarViewController)
    func titleBarViewControllerShowOutlineNotesAction(titleBarViewController: DocumentWindowTitleBarViewController)
    func titleBarViewControllerShowNotepadAction(titleBarViewController: DocumentWindowTitleBarViewController)
}

final class DocumentWindowTitleBarViewController: NSTitlebarAccessoryViewController {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet private var trafficLightContainerView: NSView?
    @IBOutlet private var notesStackView: NSStackView?
    
    // MARK: -
    // MARK: Internal Properties
    internal weak var delegate: DocumentWindowTitleBarViewControllerDelegate?
    internal var secondaryContentSupported: Bool = false {
        didSet {
            reloadNotesStackViewHidden()
        }
    }
    
    // MARK: -
    // MARK: Lifecycle
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        finishInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        finishInit()
    }
    
    private func finishInit() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterFullScreen:", name: NSWindowWillEnterFullScreenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willExitFullScreen:", name: NSWindowWillExitFullScreenNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowDidEnterFullScreenNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowWillExitFullScreenNotification, object: nil)
    }
    
    // MARK: -
    // MARK: NSViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadNotesStackViewHidden()
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction private dynamic func closeWindow(sender: AnyObject) {
        let button = view.window?.standardWindowButton(.CloseButton)
        button?.sendAction(button!.action, to: button!.target)
    }
    
    @IBAction private dynamic func minimizeWindow(sender: AnyObject) {
        let button = view.window?.standardWindowButton(.MiniaturizeButton)
        button?.sendAction(button!.action, to: button!.target)
    }
    
    @IBAction private dynamic func zoomWindow(sender: AnyObject) {
        let button = view.window?.standardWindowButton(.ZoomButton)
        button?.sendAction(button!.action, to: button!.target)
    }
    
    @IBAction private dynamic func showOutline(sender: AnyObject) {
        delegate?.titleBarViewControllerShowOutlineAction(self)
    }
    
    @IBAction private dynamic func showText(sender: AnyObject) {
        delegate?.titleBarViewControllerShowTextAction(self)
    }
    
    @IBAction private dynamic func showOutlineNotes(sender: AnyObject) {
        delegate?.titleBarViewControllerShowOutlineNotesAction(self)
    }
    
    @IBAction private dynamic func showNotepad(sender: AnyObject) {
        delegate?.titleBarViewControllerShowNotepadAction(self)
    }
    
    // MARK: -
    // MARK: Private API
    private func reloadNotesStackViewHidden() {
        notesStackView?.hidden = !secondaryContentSupported
    }
    
    // MARK: -
    // MARK: Notifications
    private dynamic func willEnterFullScreen(notification: NSNotification) {
        if notification.object as? NSWindow == view.window {
            trafficLightContainerView?.hidden = true
        }
    }
    
    private dynamic func willExitFullScreen(notification: NSNotification) {
        if notification.object as? NSWindow == view.window {
            trafficLightContainerView?.hidden = false
        }
    }
}
