//
//  AppDelegate.swift
//  WriteMac
//
//  Created by Donald Hays on 10/13/15.
//
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var libraryWindowController: LibraryWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        libraryWindowController = storyboard.instantiateControllerWithIdentifier("LibraryWindowController") as? LibraryWindowController
        libraryWindowController?.showWindow(nil)
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            libraryWindowController?.showWindow(nil)
        }
        
        return true
    }
}

