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
    @IBOutlet weak var crosshairView: CrosshairView!
    @IBOutlet weak var coordinatesLabel: NSTextField!
    @IBOutlet weak var magnificationSlider: NSSlider!

    // MARK: local variables
    let monitor = DirectoryMonitor()
    let screenshotFilePrefix = "Simulator Screen Shot"
    var latestFilePath = ""
    var trackingRectTag : NSTrackingRectTag?
    var scrollViewMousePosition : NSPoint?
    var imageMousePosition : NSPoint?
    var imageSavedMousePosition : NSPoint?
    var didAcceptMouseMoveEvents = false
    //let crosshairDelegate = CrosshairLayerDelegate()
    //let crosshairLayer = CALayer()


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
        /*self.scrollView.wantsLayer = true
        crosshairLayer.frame = self.scrollView.bounds
        crosshairLayer.delegate = self.crosshairDelegate
        self.scrollView.layer?.addSublayer(crosshairLayer)
        self.view.wantsLayer = true*/
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        //self.crosshairLayer.frame = self.scrollView.bounds
        if let tag = self.trackingRectTag {
            self.view.removeTrackingRect(tag)
        }
        self.trackingRectTag = self.view.addTrackingRect(self.scrollView.frame, owner: self, userData: nil, assumeInside: false)
    }

    // MARK: custom methods

    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        let path = directoryMonitor.URL.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "")
        if let content = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(path){
            if let latest = content.filter( { $0.hasPrefix(self.screenshotFilePrefix) } ).map( {path + $0} ).map( { FileItem(path: $0) } ).sort( { $0.compare($1) } ).last {
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

    @IBAction func magnificationValueChanged(sender: NSSlider) {
        self.scrollView.magnification = CGFloat(sender.floatValue)
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

    // MARK: mouse tracking

    override func mouseEntered(theEvent: NSEvent) {
        self.didAcceptMouseMoveEvents = self.view.window?.acceptsMouseMovedEvents ?? false
        self.view.window?.acceptsMouseMovedEvents = true
        self.view.window?.makeFirstResponder(self.view)
    }

    override func mouseExited(theEvent: NSEvent) {
        self.view.window?.acceptsMouseMovedEvents = self.didAcceptMouseMoveEvents
        self.crosshairView.crosshairLocation = nil
        self.crosshairView.needsDisplay = true
    }

    func scaleForImageHeight(height : CGFloat) -> CGFloat {
        if height < 900 {
            return 1.0
        } else if height < 1500 {
            return 0.5
        } else {
            return 1.0/3.0*1.15
        }
    }

    override func mouseMoved(theEvent: NSEvent) {
        self.scrollViewMousePosition = self.view.convertPoint(self.view.convertPoint(theEvent.locationInWindow, fromView: nil), toView: self.scrollView)
        self.crosshairView.crosshairLocation = self.scrollViewMousePosition
        self.crosshairView.needsDisplay = true
        //self.crosshairDelegate.crosshairLocation = self.view.convertPoint(self.view.convertPoint(theEvent.locationInWindow, fromView: nil), toView: self.scrollView)
        //self.crosshairLayer.setNeedsDisplay()
        //self.scrollView.needsDisplay = true

        if self.designImageView.image != nil {
            let imagePosition = self.view.convertPoint(self.view.convertPoint(theEvent.locationInWindow, fromView: nil), toView: self.designImageView)
            let scale : CGFloat = self.scaleForImageHeight(self.designImageView.image!.size.height)
            self.imageMousePosition = NSMakePoint(imagePosition.x * scale, (self.designImageView.image!.size.height - imagePosition.y)*scale)
            if let prevPos = self.imageSavedMousePosition {
                let dx = self.imageMousePosition!.x - prevPos.x
                let dy = self.imageMousePosition!.y - prevPos.y
                self.coordinatesLabel.stringValue = "\(self.imageMousePosition!.x.string(2))x\(self.imageMousePosition!.y.string(2)) \(dx.string(2))x\(dy.string(2))"
            } else {
                self.coordinatesLabel.stringValue = "\(self.imageMousePosition!.x.string(2))x\(self.imageMousePosition!.y.string(2))"
            }
        } else {
            self.coordinatesLabel.stringValue = "0x0"
        }
        //print("mouse position \(self.scrollViewMousePosition!.x)x\(self.scrollViewMousePosition!.y)")
    }

    override func keyDown(theEvent: NSEvent) {
        if theEvent.characters == "s" {
            self.crosshairView.savedLocation = self.scrollViewMousePosition
            self.imageSavedMousePosition = self.imageMousePosition
        }
        if theEvent.keyCode == 53 {
            self.crosshairView.savedLocation = nil
            self.imageSavedMousePosition = nil
            self.crosshairView.needsDisplay = true
        }
    }
}

extension CGFloat {
    func string(fractionDigits:Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.stringFromNumber(self) ?? "\(self)"
    }
}

