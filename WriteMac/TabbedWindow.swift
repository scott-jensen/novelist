//
//  TabbedWindow.swift
//  Write
//
//  Created by Donald Hays on 10/18/15.
//
//

import Cocoa

final class TabbedWindow: NSWindow {
    // MARK: -
    // MARK: Lifecycle
    override init(contentRect: NSRect, styleMask aStyle: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        finishInit()
    }
    
    fileprivate func finishInit() {
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        
        hideStandardButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TabbedWindow.didEnterFullScreen(_:)), name: NSNotification.Name.NSWindowDidEnterFullScreen, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(TabbedWindow.willExitFullScreen(_:)), name: NSNotification.Name.NSWindowWillExitFullScreen, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSWindowDidEnterFullScreen, object: self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSWindowWillExitFullScreen, object: self)
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func showStandardButtons() {
        standardWindowButton(.closeButton)!.isHidden = false
        standardWindowButton(.miniaturizeButton)!.isHidden = false
        standardWindowButton(.zoomButton)!.isHidden = false
    }
    
    fileprivate func hideStandardButtons() {
        standardWindowButton(.closeButton)!.isHidden = true
        standardWindowButton(.miniaturizeButton)!.isHidden = true
        standardWindowButton(.zoomButton)!.isHidden = true
    }
    
    // MARK: -
    // MARK: Notifications
    fileprivate dynamic func didEnterFullScreen(_ notification: Notification) {
        showStandardButtons()
    }
    
    fileprivate dynamic func willExitFullScreen(_ notification: Notification) {
        hideStandardButtons()
    }
}
