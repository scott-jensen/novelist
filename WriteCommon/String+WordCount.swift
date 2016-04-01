//
//  String+WordCount.swift
//  Write
//
//  Created by Donald Hays on 11/8/15.
//
//

import Foundation

public extension String {
    var wordCount: Int {
        let locale = CFLocaleCopyCurrent()
        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, self, CFRange(location: 0, length: CFStringGetLength(self)), kCFStringTokenizerUnitWord, locale)
        
        var count = 0
        while CFStringTokenizerAdvanceToNextToken(tokenizer) != .None {
            count++
        }
        
        return count
    }
}
