//
//  PaneContainerView.swift
//  Write
//
//  Created by Donald Hays on 10/19/15.
//
//

import Cocoa

final class PaneContainerView: NSView {
    @IBInspectable var intrinsicWidth: CGFloat = 100
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: intrinsicWidth, height: 100)
    }
}
