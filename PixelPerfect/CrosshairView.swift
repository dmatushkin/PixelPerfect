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

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        if let position = self.crosshairLocation {
            NSGraphicsContext.saveGraphicsState()
            NSColor.blackColor().setStroke()
            NSBezierPath.strokeLineFromPoint(NSMakePoint(0, self.frame.size.height - position.y), toPoint: NSMakePoint(self.frame.size.width, self.frame.size.height - position.y))
            NSBezierPath.strokeLineFromPoint(NSMakePoint(position.x, 0), toPoint: NSMakePoint(position.x, self.frame.size.height))
            NSGraphicsContext.restoreGraphicsState()
        }
        if let position = self.savedLocation {
            NSGraphicsContext.saveGraphicsState()
            NSColor.blackColor().setStroke()
            NSBezierPath.strokeLineFromPoint(NSMakePoint(0, self.frame.size.height - position.y), toPoint: NSMakePoint(self.frame.size.width, self.frame.size.height - position.y))
            NSBezierPath.strokeLineFromPoint(NSMakePoint(position.x, 0), toPoint: NSMakePoint(position.x, self.frame.size.height))
            NSGraphicsContext.restoreGraphicsState()
        }
    }

}
