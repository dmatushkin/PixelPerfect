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

    @IBAction func openDesignAction(_ sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        let result = panel.runModal()
        if result == NSModalResponseOK {
            if let path = panel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") {
                if let controller = NSApplication.shared().mainWindow?.contentViewController as? ViewController {
                    controller.setDesign(path)
                }
            }
        }
    }

    @IBAction func setScreenshotFolder(_ sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        let result = panel.runModal()
        if result == NSModalResponseOK {
            if let path = panel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") {
                if let controller = NSApplication.shared().mainWindow?.contentViewController as? ViewController {
                    controller.setScreenshotFolder(path)
                }
            }
        }
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if let controller = NSApplication.shared().mainWindow?.contentViewController as? ViewController, let filename = filenames.first {
            controller.setDesign(filename.replacingOccurrences(of: "file://", with: ""))
        }
    }

    func alertWithMessage(_ message : String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        if let controller = NSApplication.shared().mainWindow?.contentViewController as? ViewController {
            controller.setDesign(filename.replacingOccurrences(of: "file://", with: ""))
            return true
        }
        return false
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

