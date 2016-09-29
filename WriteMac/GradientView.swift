//
//  GradientView.swift
//  Write
//
//  Created by Donald Hays on 10/18/15.
//
//

import Cocoa

final class GradientView: NSView {
    // MARK: -
    // MARK: NSView
    override func draw(_ dirtyRect: NSRect) {
        let gradient = NSGradient(colors: [NSColor(red: 0.12, green: 0.15, blue: 0.19, alpha: 1.0), NSColor.black])!
        gradient.draw(in: bounds, angle: -90)
    }
}
