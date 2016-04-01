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
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, `defer` flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, `defer`: flag)
        
        finishInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        finishInit()
    }
    
    private func finishInit() {
        titleVisibility = .Hidden
        titlebarAppearsTransparent = true
        
        hideStandardButtons()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterFullScreen:", name: NSWindowDidEnterFullScreenNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willExitFullScreen:", name: NSWindowWillExitFullScreenNotification, object: self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowDidEnterFullScreenNotification, object: self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowWillExitFullScreenNotification, object: self)
    }
    
    // MARK: -
    // MARK: Private API
    private func showStandardButtons() {
        standardWindowButton(.CloseButton)!.hidden = false
        standardWindowButton(.MiniaturizeButton)!.hidden = false
        standardWindowButton(.ZoomButton)!.hidden = false
    }
    
    private func hideStandardButtons() {
        standardWindowButton(.CloseButton)!.hidden = true
        standardWindowButton(.MiniaturizeButton)!.hidden = true
        standardWindowButton(.ZoomButton)!.hidden = true
    }
    
    // MARK: -
    // MARK: Notifications
    private dynamic func didEnterFullScreen(notification: NSNotification) {
        showStandardButtons()
    }
    
    private dynamic func willExitFullScreen(notification: NSNotification) {
        hideStandardButtons()
    }
}
