//
//  ScrubBarView.swift
//  Write
//
//  Created by Donald Hays on 11/30/15.
//
//

import Cocoa
import RealmSwift

@IBDesignable final class ScrubBarView: NSView {
    // MARK: -
    // MARK: Private Properties
    fileprivate var wordCounts: [Int] {
        // Adding 10 to every word count to give me a bit of minimum spacing.
        return book?.chapters.map { $0.wordCount + 10 } ?? []
    }
    
    fileprivate let textAttributes: [String: AnyObject] = {
        return [
            NSFontAttributeName : NSFont.systemFont(ofSize: 12),
            NSForegroundColorAttributeName : NSColor.white
        ]
    }()
    
    fileprivate var notificationToken: NotificationToken?
    
    // MARK: -
    // MARK: Internal Properties
    internal var state: DocumentWindowState? {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    internal var book: Book? {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    // MARK: -
    // MARK: NSView
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        
        if newWindow != nil && notificationToken == nil {
            notificationToken = DataCenter.sharedCenter.realm.addNotificationBlock { [weak self] notification, realm in
                if let view = self {
                    view.setNeedsDisplay(view.bounds)
                }
            }
        } else if let notificationToken = notificationToken {
            notificationToken.stop()
            self.notificationToken = nil
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        drawBackground()
        
        guard let book = book , book.chapters.count > 0 else {
            return
        }
        
        let wordCounts = self.wordCounts
        let totalWords = wordCounts.reduce(0) { $0 + $1 }
        
        // Give number displaying priority to the longest chapters
        
        let stringHeight = "M".size(withAttributes: textAttributes).height
        let stringBottom = floor((bounds.height - stringHeight) / 2)
        let numberStrings = [Int]((0 ..< book.chapters.count)).map { "\($0 + 1)" }
        let numberStringSizes = numberStrings.map { ceil($0.size(withAttributes: textAttributes).width) + 10 }
        let numberStringSizesTotal = numberStringSizes.reduce(0) { $0 + $1 }
        let totalLineWidth = bounds.size.width - 20
        let lineWidth = totalLineWidth - numberStringSizesTotal
        let bottom = floor(bounds.height / 2) - 1
        var left: CGFloat = 10
        for index in 0 ..< numberStrings.count {
            let numberString = numberStrings[index]
            numberString.draw(at: NSPoint(x: left + 5, y: stringBottom), withAttributes: textAttributes)
            left += numberStringSizes[index]
            
            let lineSegmentWidth: CGFloat
            if index < numberStrings.count - 1 {
                lineSegmentWidth = floor((CGFloat(wordCounts[index]) / CGFloat(totalWords)) * lineWidth)
            } else {
                lineSegmentWidth = (bounds.width - left) - 10
            }
            
            NSColor(red: 0.25, green: 0.25, blue: 0.26, alpha: 1.0).set()
            NSBezierPath.fill(NSRect(x: left, y: bottom, width: lineSegmentWidth, height: 1))
            left += lineSegmentWidth
        }
    }
    
    // MARK: -
    // MARK: Private API
    fileprivate func drawBackground() {
        NSColor(red: 0.09, green: 0.09, blue: 0.10, alpha: 1.00).set()
        NSBezierPath.fill(bounds)
    }
}
