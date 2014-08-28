//
//  SelectActionViewController.swift
//  SayCheese
//
//  Created by Arasthel on 16/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Foundation

class SelectActionViewController: NSViewController {
    
    var screenshotDelegate: ScreenshotDelegate?
    
    override init() {
        super.init(nibName: "SelectActionView", bundle: NSBundle.mainBundle())
    }
    
    
    required init(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
@IBAction func saveImage(sender: AnyObject?) {
        if screenshotDelegate? != nil {
            screenshotDelegate!.saveImage()
        }
    }
    
    @IBAction func uploadImage(sender: AnyObject?) {
        if screenshotDelegate? != nil {
            screenshotDelegate!.uploadImage()
        }
    }
    
    @IBAction func quit(sender: AnyObject?) {
        if screenshotDelegate? != nil {
            screenshotDelegate!.closeWindow()
        }
    }
    
}