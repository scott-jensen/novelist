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
    fileprivate var libraryWindowController: LibraryWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        libraryWindowController = storyboard.instantiateController(withIdentifier: "LibraryWindowController") as? LibraryWindowController
        libraryWindowController?.showWindow(nil)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            libraryWindowController?.showWindow(nil)
        }
        
        return true
    }
}

