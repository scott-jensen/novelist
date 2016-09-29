//
//  TextView.swift
//  Write
//
//  Created by Donald Hays on 11/30/15.
//
//

import Cocoa

final class TextView: NSTextView {
    override var intrinsicContentSize: NSSize {
        guard let textContainer = textContainer, let layoutManager = layoutManager else {
            return NSSize(width: 32, height: 32)
        }
        
        layoutManager.ensureLayout(for: textContainer)
        return layoutManager.usedRect(for: textContainer).size
    }
    
    // MARK: -
    // MARK: NSTextView
    override func didChangeText() {
        super.didChangeText()
        self.invalidateIntrinsicContentSize()
    }
}
