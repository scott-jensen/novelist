//
//  TrafficButton.swift
//  Write
//
//  Created by Donald Hays on 10/18/15.
//
//

import Cocoa

final class TrafficButton: NSControl {
    override func draw(_ dirtyRect: NSRect) {
        NSImage(named: "traffic")?.draw(in: bounds)
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let point = convert(theEvent.locationInWindow, from: nil)
        if bounds.contains(point) {
            sendAction(action, to: target)
        }
    }
}
