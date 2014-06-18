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
    
    init() {
        super.init(nibName: "SelectActionView", bundle: NSBundle.mainBundle())
    }
    
    @IBAction func saveImage(sender: AnyObject?) {
        if screenshotDelegate? {
            screenshotDelegate!.saveImage()
        }
    }
    
    @IBAction func uploadImage(sender: AnyObject?) {
        if screenshotDelegate? {
            screenshotDelegate!.uploadImage()
        }
    }
    
    @IBAction func quit(sender: AnyObject?) {
        if screenshotDelegate? {
            screenshotDelegate!.closeWindow()
        }
    }
    
}