//
//  ViewController.swift
//  PixelPerfect
//
//  Created by Dmitry Matyushkin on 12/9/15.
//  Copyright © 2015 Dmitry Matyushkin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, DirectoryMonitorDelegate {

    enum MouseFollowMode {
        case hasNoPoints
        case hasOnePoint
        case hasTwoPoints
    }

    // MARK: outlets
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var designImageView: NSImageView!
    @IBOutlet weak var screenshotImageView: NSImageView!
    @IBOutlet weak var opacitySlider: NSSlider!
    @IBOutlet weak var crosshairView: CrosshairView!
    @IBOutlet weak var coordinatesLabel: NSTextField!

    // MARK: local variables
    let monitor = DirectoryMonitor()
    let screenshotFilePrefix = "Simulator Screen Shot"
    var latestFilePath = ""
    var trackingRectTag : NSTrackingRectTag?
    var scrollViewMousePosition : NSPoint?
    var imageMousePosition : NSPoint?
    var imageSavedMousePosition : NSPoint?
    var mouseMode = MouseFollowMode.hasNoPoints


    // MARK: controller workflow
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.allowsMagnification = true
        self.scrollView.maxMagnification = 100.0
        self.scrollView.minMagnification = 0.001
        self.screenshotImageView.alphaValue = CGFloat(self.opacitySlider.floatValue)
        self.monitor.delegate = self
        self.monitor.startMonitoring()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        if let tag = self.trackingRectTag {
            self.view.removeTrackingRect(tag)
        }
        self.trackingRectTag = self.view.addTrackingRect(self.scrollView.frame, owner: self, userData: nil, assumeInside: false)
    }

    // MARK: custom methods

    func directoryMonitorDidObserveChange(_ directoryMonitor: DirectoryMonitor) {
        let path = directoryMonitor.URL.absoluteString.replacingOccurrences(of: "file://", with: "")
        if let content = try? FileManager.default.contentsOfDirectory(atPath: path){
            if let latest = content.filter( { $0.hasPrefix(self.screenshotFilePrefix) } ).map( {path + $0} ).map( { FileItem(path: $0) } ).sorted( by: { $0.compare($1) } ).last {
                if latest.filePath != self.latestFilePath {
                    self.latestFilePath = latest.filePath
                    DispatchQueue.main.async {
                        self.screenshotImageView.image = NSImage(contentsOfFile: self.latestFilePath)
                    }
                }
            }

        }
    }
    
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        self.screenshotImageView.alphaValue = CGFloat(sender.floatValue)
    }

    func setDesign(_ path : String) {
        self.designImageView.image = NSImage(contentsOfFile: path)
        self.screenshotImageView.image = nil
    }

    func setScreenshotFolder(_ path : String) {
        self.monitor.stopMonitoring()
        self.monitor.URL = URL(fileURLWithPath: path)
        self.monitor.startMonitoring()
    }

    // MARK: mouse tracking

    override func mouseEntered(with theEvent: NSEvent) {
        self.view.window?.acceptsMouseMovedEvents = true
        self.view.window?.makeFirstResponder(self.view)
    }

    override func mouseExited(with theEvent: NSEvent) {
        self.view.window?.acceptsMouseMovedEvents = false
        if self.mouseMode != MouseFollowMode.hasTwoPoints {
            self.scrollViewMousePosition = nil
            self.setCrosshairMainPosition()
        }
    }

    func reloadCrosshair() {
        self.crosshairView.needsDisplay = true
    }

    func setCrosshairMainPosition() {
        self.crosshairView.crosshairLocation = self.scrollViewMousePosition
        self.reloadCrosshair()
    }

    func setCrosshairOriginPosition() {
        self.crosshairView.savedLocation = self.scrollViewMousePosition
        self.reloadCrosshair()
    }

    func scaleForImageHeight(_ height : CGFloat) -> CGFloat {
        if height < 900 {
            return 1.0
        } else if height < 1500 {
            return 0.5
        } else {
            return 1.0/3.0*1.15
        }
    }

    override func mouseMoved(with theEvent: NSEvent) {
        self.scrollViewMousePosition = self.view.convert(self.view.convert(theEvent.locationInWindow, from: nil), to: self.scrollView)
        if self.mouseMode != MouseFollowMode.hasTwoPoints  {
            self.setCrosshairMainPosition()

            if self.designImageView.image != nil {
                let imagePosition = self.view.convert(self.view.convert(theEvent.locationInWindow, from: nil), to: self.designImageView)
                let scale : CGFloat = self.scaleForImageHeight(self.designImageView.image!.size.height)
                self.imageMousePosition = NSMakePoint(imagePosition.x * scale, (self.designImageView.image!.size.height - imagePosition.y)*scale)
                if let prevPos = self.imageSavedMousePosition {
                    let dx = self.imageMousePosition!.x - prevPos.x
                    let dy = self.imageMousePosition!.y - prevPos.y
                    self.coordinatesLabel.stringValue = "\(prevPos.x.string)x\(prevPos.y.string) \(dx.string)x\(dy.string)"
                } else {
                    self.coordinatesLabel.stringValue = "\(self.imageMousePosition!.x.string)x\(self.imageMousePosition!.y.string)"
                }
            } else {
                self.coordinatesLabel.stringValue = "0x0"
            }
        }
    }

    override func keyDown(with theEvent: NSEvent) {
        switch(theEvent.keyCode) {
        case 1:
            self.toggleSelection()
        case 53:
            self.cancelSelection()
        default:
            break
        }
    }

    func toggleSelection() {
        if self.mouseMode == MouseFollowMode.hasNoPoints {
            self.setCrosshairOriginPosition()
            self.imageSavedMousePosition = self.imageMousePosition
            self.mouseMode = MouseFollowMode.hasOnePoint
        } else if self.mouseMode == MouseFollowMode.hasOnePoint {
            self.mouseMode = MouseFollowMode.hasTwoPoints
        } else if self.mouseMode == MouseFollowMode.hasTwoPoints {
            self.cancelSelection()
        }
    }

    func cancelSelection() {
        self.mouseMode = MouseFollowMode.hasNoPoints
        self.imageSavedMousePosition = nil
        self.scrollViewMousePosition = nil
        self.setCrosshairOriginPosition()
        self.setCrosshairMainPosition()
    }
}

extension CGFloat {
    var string : String {
        get {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: Float(self))) ?? "\(self)"
        }
    }
}

