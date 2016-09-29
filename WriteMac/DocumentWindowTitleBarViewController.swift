//
//  DocumentWindowTitleBarViewController.swift
//  Write
//
//  Created by Donald Hays on 10/18/15.
//
//

import Cocoa

@objc protocol DocumentWindowTitleBarViewControllerDelegate {
    func titleBarViewControllerShowOutlineAction(_ titleBarViewController: DocumentWindowTitleBarViewController)
    func titleBarViewControllerShowTextAction(_ titleBarViewController: DocumentWindowTitleBarViewController)
    func titleBarViewControllerShowOutlineNotesAction(_ titleBarViewController: DocumentWindowTitleBarViewController)
    func titleBarViewControllerShowNotepadAction(_ titleBarViewController: DocumentWindowTitleBarViewController)
}

final class DocumentWindowTitleBarViewController: NSTitlebarAccessoryViewController {
    // MARK: -
    // MARK: Private Properties
    @IBOutlet fileprivate var trafficLightContainerView: NSView?
    @IBOutlet fileprivate var notesStackView: NSStackView?
    
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
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        finishInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        finishInit()
    }
    
    fileprivate func finishInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentWindowTitleBarViewController.willEnterFullScreen(_:)), name: NSNotification.Name.NSWindowWillEnterFullScreen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentWindowTitleBarViewController.willExitFullScreen(_:)), name: NSNotification.Name.NSWindowWillExitFullScreen, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSWindowDidEnterFullScreen, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSWindowWillExitFullScreen, object: nil)
    }
    
    // MARK: -
    // MARK: NSViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadNotesStackViewHidden()
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction fileprivate dynamic func closeWindow(_ sender: AnyObject) {
        let button = view.window?.standardWindowButton(.closeButton)
        button?.sendAction(button!.action, to: button!.target)
    }
    
    @IBAction fileprivate dynamic func minimizeWindow(_ sender: AnyObject) {
        let button = view.window?.standardWindowButton(.miniaturizeButton)
        button?.sendAction(button!.action, to: button!.target)
    }
    
    @IBAction fileprivate dynamic func zoomWindow(_ sender: AnyObject) {
        let button = view.window?.standardWindowButton(.zoomButton)
        button?.sendAction(button!.action, to: button!.target)
    }
    
    @IBAction fileprivate dynamic func showOutline(_ sender: AnyObject) {
        delegate?.titleBarViewControllerShowOutlineAction(self)
    }
    
    @IBAction fileprivate dynamic func showText(_ sender: AnyObject) {
        delegate?.titleBarViewControllerShowTextAction(self)
    }
    
    @IBAction fileprivate dynamic func showOutlineNotes(_ sender: AnyObject) {
        delegate?.titleBarViewControllerShowOutlineNotesAction(self)
    }
    
    @IBAction fileprivate dynamic func showNotepad(_ sender: AnyObject) {
        delegate?.titleBarViewControllerShowNotepadAction(self)
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func reloadNotesStackViewHidden() {
        notesStackView?.isHidden = !secondaryContentSupported
    }
    
    // MARK: -
    // MARK: Notifications
    fileprivate dynamic func willEnterFullScreen(_ notification: Notification) {
        if notification.object as? NSWindow == view.window {
            trafficLightContainerView?.isHidden = true
        }
    }
    
    fileprivate dynamic func willExitFullScreen(_ notification: Notification) {
        if notification.object as? NSWindow == view.window {
            trafficLightContainerView?.isHidden = false
        }
    }
}
