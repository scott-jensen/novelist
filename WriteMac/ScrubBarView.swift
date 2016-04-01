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
    private var wordCounts: [Int] {
        // Adding 10 to every word count to give me a bit of minimum spacing.
        return book?.chapters.map { $0.wordCount + 10 } ?? []
    }
    
    private let textAttributes: [String: AnyObject] = {
        return [
            NSFontAttributeName : NSFont.systemFontOfSize(12),
            NSForegroundColorAttributeName : NSColor.whiteColor()
        ]
    }()
    
    private var notificationToken: NotificationToken?
    
    // MARK: -
    // MARK: Internal Properties
    internal var state: DocumentWindowState? {
        didSet {
            setNeedsDisplayInRect(bounds)
        }
    }
    
    internal var book: Book? {
        didSet {
            setNeedsDisplayInRect(bounds)
        }
    }
    
    // MARK: -
    // MARK: NSView
    override func viewWillMoveToWindow(newWindow: NSWindow?) {
        super.viewWillMoveToWindow(newWindow)
        
        if newWindow != nil && notificationToken == nil {
            notificationToken = DataCenter.sharedCenter.realm.addNotificationBlock { [weak self] notification, realm in
                if let view = self {
                    view.setNeedsDisplayInRect(view.bounds)
                }
            }
        } else if let notificationToken = notificationToken {
            DataCenter.sharedCenter.realm.removeNotification(notificationToken)
            self.notificationToken = nil
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        drawBackground()
        
        guard let book = book where book.chapters.count > 0 else {
            return
        }
        
        let wordCounts = self.wordCounts
        let totalWords = wordCounts.reduce(0) { $0 + $1 }
        
        // Give number displaying priority to the longest chapters
        
        let stringHeight = "M".sizeWithAttributes(textAttributes).height
        let stringBottom = floor((bounds.height - stringHeight) / 2)
        let numberStrings = [Int]((0 ..< book.chapters.count)).map { "\($0 + 1)" }
        let numberStringSizes = numberStrings.map { ceil($0.sizeWithAttributes(textAttributes).width) + 10 }
        let numberStringSizesTotal = numberStringSizes.reduce(0) { $0 + $1 }
        let totalLineWidth = bounds.size.width - 20
        let lineWidth = totalLineWidth - numberStringSizesTotal
        let bottom = floor(bounds.height / 2) - 1
        var left: CGFloat = 10
        for index in 0 ..< numberStrings.count {
            let numberString = numberStrings[index]
            numberString.drawAtPoint(NSPoint(x: left + 5, y: stringBottom), withAttributes: textAttributes)
            left += numberStringSizes[index]
            
            let lineSegmentWidth: CGFloat
            if index < numberStrings.count - 1 {
                lineSegmentWidth = floor((CGFloat(wordCounts[index]) / CGFloat(totalWords)) * lineWidth)
            } else {
                lineSegmentWidth = (bounds.width - left) - 10
            }
            
            NSColor(red: 0.25, green: 0.25, blue: 0.26, alpha: 1.0).set()
            NSBezierPath.fillRect(NSRect(x: left, y: bottom, width: lineSegmentWidth, height: 1))
            left += lineSegmentWidth
        }
    }
    
    // MARK: -
    // MARK: Private API
    private func drawBackground() {
        NSColor(red: 0.09, green: 0.09, blue: 0.10, alpha: 1.00).set()
        NSBezierPath.fillRect(bounds)
    }
}
