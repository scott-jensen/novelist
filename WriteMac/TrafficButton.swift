//
//  TrafficButton.swift
//  Write
//
//  Created by Donald Hays on 10/18/15.
//
//

import Cocoa

final class TrafficButton: NSControl {
    override func drawRect(dirtyRect: NSRect) {
        NSImage(named: "traffic")?.drawInRect(bounds)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        let point = convertPoint(theEvent.locationInWindow, fromView: nil)
        if bounds.contains(point) {
            sendAction(action, to: target)
        }
    }
}
