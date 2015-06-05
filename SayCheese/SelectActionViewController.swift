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
    
    override init!(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "SelectActionView", bundle: NSBundle.mainBundle())
    }
    
    // need this, too, or the compiler will complain that it's missing
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    
    
    @IBAction func saveImage(sender: AnyObject?) {
        if screenshotDelegate != nil {
            screenshotDelegate!.saveImage()
        }
    }
    
    @IBAction func uploadImage(sender: AnyObject?) {
        if screenshotDelegate != nil {
            screenshotDelegate!.uploadImage()
        }
    }
    
    @IBAction func quit(sender: AnyObject?) {
        if screenshotDelegate != nil {
            screenshotDelegate!.closeWindow()
        }
    }
    
}