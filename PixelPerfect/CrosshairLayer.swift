//
//  CrosshairLayer.swift
//  PixelPerfect
//
//  Created by Dmitry Matyushkin on 12/10/15.
//  Copyright © 2015 Dmitry Matyushkin. All rights reserved.
//

import Cocoa

class CrosshairLayerDelegate {
    var crosshairLocation : NSPoint?
    var savedLocation : NSPoint?

    func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        let context = NSGraphicsContext(CGContext: ctx, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrentContext(context)
        NSColor.blackColor().setStroke()
        if let position = self.crosshairLocation {
            NSBezierPath.strokeLineFromPoint(NSMakePoint(0, layer.frame.size.height - position.y), toPoint: NSMakePoint(layer.frame.size.width, layer.frame.size.height - position.y))
            NSBezierPath.strokeLineFromPoint(NSMakePoint(position.x, 0), toPoint: NSMakePoint(position.x, layer.frame.size.height))
        }
        if let position = self.savedLocation {
            NSBezierPath.strokeLineFromPoint(NSMakePoint(0, layer.frame.size.height - position.y), toPoint: NSMakePoint(layer.frame.size.width, layer.frame.size.height - position.y))
            NSBezierPath.strokeLineFromPoint(NSMakePoint(position.x, 0), toPoint: NSMakePoint(position.x, layer.frame.size.height))
        }
        NSGraphicsContext.restoreGraphicsState()
    }
}

class CrosshairLayer: CALayer {

    private let crosshairDelegate = CrosshairLayerDelegate()

    var crosshairLocation : NSPoint? {
        didSet {
            self.crosshairDelegate.crosshairLocation = self.crosshairLocation
            self.setNeedsDisplay()
        }
    }

    override init() {
        super.init()
        self.delegate = self.crosshairDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
