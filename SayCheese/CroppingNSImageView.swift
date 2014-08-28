//
//  CroppingNSImageView.swift
//  SayCheese
//
//  Created by Jorge Martín Espinosa on 14/6/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Cocoa
import QuartzCore

class CroppingNSView: NSView {

    weak var image: NSImage?
    var clickedPoint: NSPoint?
    var shapeLayer: CAShapeLayer?
    var screenshotDelegate: ScreenshotDelegate?
    var canDrag: Bool?
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        clickedPoint = nil
        
        self.layer = CALayer()
        self.layer!.frame = frame
        self.wantsLayer = true
        
        shapeLayer = CAShapeLayer()
        shapeLayer!.lineWidth = 1.0
        shapeLayer!.strokeColor = NSColor.blackColor().CGColor
        shapeLayer!.fillColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0.4).CGColor
        shapeLayer!.lineDashPattern = [10, 5]
        
        canDrag = true
        
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageForBackground(newImage: NSImage, withSize size: NSSize) {
        image = newImage
        self.layer!.backgroundColor = NSColor(patternImage: image!.hh_imageTintedWithColor(NSColor(red: 0, green: 0, blue: 0, alpha: 1.0))).CGColor
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        if canDrag!  == true {
            clickedPoint = convertPoint(theEvent.locationInWindow, fromView: nil)
            self.layer!.addSublayer(shapeLayer!)
        }
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        
        canDrag = false
        
        if (screenshotDelegate? != nil) {
            
            let point = convertPoint(theEvent.locationInWindow, fromView: nil)
            
            let selectedRect = CGRectMake(min(point.x, clickedPoint!.x),
                min(point.y, clickedPoint!.y),
                fabs(point.x - clickedPoint!.x),
                fabs(point.y - clickedPoint!.y)
            )
            
            if (image? != nil) {
                let croppedImage = NSImage(size: NSSizeFromCGSize(CGSize(width: selectedRect.width, height: selectedRect.height)))
                croppedImage.lockFocus()
                image!.drawAtPoint(NSZeroPoint, fromRect: selectedRect, operation: .CompositeCopy, fraction: 1.0)
                croppedImage.unlockFocus()
                screenshotDelegate!.regionSelected(croppedImage)
            }
        }
    }
    
    override func mouseDragged(theEvent: NSEvent!) {
        let point = convertPoint(theEvent.locationInWindow, fromView: nil)
        
        var path = CGPathCreateMutable()
        if let startPoint = clickedPoint? {
            CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y)
            CGPathAddLineToPoint(path, nil, startPoint.x, point.y)
            CGPathAddLineToPoint(path, nil, point.x, point.y)
            CGPathAddLineToPoint(path, nil, point.x, startPoint.y)
            CGPathCloseSubpath(path)
        }
        
        shapeLayer!.path = path!
    }
    
    func releaseImage() {
        image = nil
        shapeLayer!.path = nil
        shapeLayer!.removeFromSuperlayer()
        layer!.backgroundColor = NSColor.clearColor().CGColor
    }
}
