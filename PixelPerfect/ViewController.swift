//
//  ViewController.swift
//  PixelPerfect
//
//  Created by Dmitry Matyushkin on 12/9/15.
//  Copyright © 2015 Dmitry Matyushkin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, DirectoryMonitorDelegate {

    // MARK: outlets
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var designImageView: NSImageView!
    @IBOutlet weak var screenshotImageView: NSImageView!
    @IBOutlet weak var opacitySlider: NSSlider!

    // MARK: local variables
    let monitor = DirectoryMonitor()
    let screenshotFilePrefix = "Simulator Screen Shot"
    var latestFilePath = ""


    // MARK: controller workflow
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.allowsMagnification = true
        self.scrollView.maxMagnification = 100.0
        self.scrollView.minMagnification = 0.001
        //self.designImageView.image = NSImage(contentsOfFile: "/Users/dmatushkin/Downloads/my-settings-specs/JPEG/6.jpg")
        self.screenshotImageView.alphaValue = CGFloat(self.opacitySlider.floatValue)
        self.monitor.delegate = self
        self.monitor.startMonitoring()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: custom methods

    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        let path = directoryMonitor.URL.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "")
        if let content = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(path){
            if let latest = content.filter( { $0.hasPrefix(self.screenshotFilePrefix) } ).map( {path + $0} ).map( { FileItem(path: $0) } ).sort( { $0.dateCreated.compare($1.dateCreated) == NSComparisonResult.OrderedAscending } ).last {
                if latest.filePath != self.latestFilePath {
                    self.latestFilePath = latest.filePath
                    dispatch_async(dispatch_get_main_queue()) {
                        self.screenshotImageView.image = NSImage(contentsOfFile: self.latestFilePath)
                    }
                }
            }

        }
    }
    
    @IBAction func sliderValueChanged(sender: NSSlider) {
        self.screenshotImageView.alphaValue = CGFloat(sender.floatValue)
    }

    func setDesign(path : String) {
        self.designImageView.image = NSImage(contentsOfFile: path)
        self.screenshotImageView.image = nil
    }

    func setScreenshotFolder(path : String) {
        self.monitor.stopMonitoring()
        self.monitor.URL = NSURL(fileURLWithPath: path)
        self.monitor.startMonitoring()
    }
}

