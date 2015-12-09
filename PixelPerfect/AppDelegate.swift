//
//  AppDelegate.swift
//  PixelPerfect
//
//  Created by Dmitry Matyushkin on 12/9/15.
//  Copyright © 2015 Dmitry Matyushkin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func openDesignAction(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        let result = panel.runModal()
        if result == NSModalResponseOK {
            if let path = panel.URLs.first?.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "") {
                if let controller = NSApplication.sharedApplication().mainWindow?.contentViewController as? ViewController {
                    controller.setDesign(path)
                }
            }
        }
    }

    @IBAction func setScreenshotFolder(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        let result = panel.runModal()
        if result == NSModalResponseOK {
            if let path = panel.URLs.first?.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "") {
                if let controller = NSApplication.sharedApplication().mainWindow?.contentViewController as? ViewController {
                    controller.setScreenshotFolder(path)
                }
            }
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

