//
//  CrosshairView.swift
//  PixelPerfect
//
//  Created by Dmitry Matyushkin on 12/10/15.
//  Copyright © 2015 Dmitry Matyushkin. All rights reserved.
//

import Cocoa

class CrosshairView: NSView {

    var crosshairLocation : NSPoint?
    var savedLocation : NSPoint?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSGraphicsContext.saveGraphicsState()
        NSColor.black.setStroke()
        if let position = self.crosshairLocation {
            NSBezierPath.strokeLine(from: NSMakePoint(0, self.frame.size.height - position.y), to: NSMakePoint(self.frame.size.width, self.frame.size.height - position.y))
            NSBezierPath.strokeLine(from: NSMakePoint(position.x, 0), to: NSMakePoint(position.x, self.frame.size.height))
        }
        if let position = self.savedLocation {
            NSBezierPath.strokeLine(from: NSMakePoint(0, self.frame.size.height - position.y), to: NSMakePoint(self.frame.size.width, self.frame.size.height - position.y))
            NSBezierPath.strokeLine(from: NSMakePoint(position.x, 0), to: NSMakePoint(position.x, self.frame.size.height))
        }
        NSGraphicsContext.restoreGraphicsState()
    }

    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
}
