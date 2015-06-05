//
//  ScreenshotWindow.swift
//  SayCheese
//
//  Created by Jorge Martín Espinosa on 13/6/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Cocoa
import QuartzCore


class ScreenshotWindow: NSWindowController, ScreenshotDelegate, NSWindowDelegate {
    
    var selectedImage: NSImage?
    var backgroundImage: NSImage?
    var imageView: CroppingNSView?
    var savePanel: NSSavePanel?
    var imgurClient: ImgurClient?
    var selectActionView: SelectActionViewController?
    var confirmAnonymous: ConfirmAnonymousUploadPanelController?
    
    override init(window: NSWindow!) {
        super.init(window: window)
        window.delegate = self
        window.releasedWhenClosed = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func showWindow(sender: AnyObject!) {
        window!.makeKeyAndOrderFront(self)
        // Set level to screensaver level
        window!.level = 1000
        
        // Set image cropping view as the contentView
        imageView = CroppingNSView(frame: window!.frame)
        imageView!.screenshotDelegate = self
        window!.contentView = imageView!
    }
    
    func paintImage(image: NSImage, withSize size: NSSize) {
        backgroundImage = image
        imageView!.setImageForBackground(backgroundImage!, withSize: size)
    }
    
    func regionSelected(image: NSImage) {
        // Add SelectActionViewController to the middle-bottom of the screen
        selectActionView = SelectActionViewController()
        selectActionView!.screenshotDelegate = self
        let newFrame = NSRectFromCGRect(CGRectMake(window!.frame.size.width/2 - selectActionView!.view.frame.width/2,
            60, selectActionView!.view.frame.width, selectActionView!.view.frame.height))
        selectActionView!.view.frame = newFrame
        (window!.contentView as! NSView).addSubview(selectActionView!.view)
        
        // Keep a reference to the selected image so it can be saved or uploaded later
        selectedImage = image
    }
    
    func uploadPicture(image: NSImage) {
        imgurClient!.uploadImage(image)
    }
    
    func savePicture(image: NSImage) {
        // Instantiate savePanel
        savePanel = NSSavePanel()
        savePanel!.allowedFileTypes = ["png", "jpg"]
        savePanel!.allowsOtherFileTypes = false
        savePanel!.extensionHidden = false
        
        let fileFormatView = NSView(frame: NSMakeRect(0, 0, savePanel!.frame.size.width, 40))
        let center = savePanel!.frame.size.width/2
        let pullDownView = NSPopUpButton(frame: NSMakeRect(center+40, 0, 80, 40))
        
        // Add an "Extension:" label
        let extensionLabel = NSTextField(frame: NSMakeRect(center-50, 10, 80, 20))
        extensionLabel.stringValue = "Extension: "
        extensionLabel.bezeled = false
        extensionLabel.drawsBackground = false
        extensionLabel.editable = false
        extensionLabel.selectable = false
        extensionLabel.alignment = NSTextAlignment.RightTextAlignment
        
        // Add a NSPopUpMenu with the available extensions
        pullDownView.addItemsWithTitles(savePanel!.allowedFileTypes!)
        pullDownView.action = "dropMenuChange:"
        pullDownView.target = self
        fileFormatView.addSubview(pullDownView)
        fileFormatView.addSubview(extensionLabel)
        
        // Set the container view as the accessory view
        savePanel!.accessoryView = fileFormatView
        
        // Send window back so we can see the modal NSSavePanel
        window!.level = 2
        
        // Launch save dialog
        let saveResult = savePanel!.runModal()
        
        // If user selects "Save"
        if saveResult == NSOKButton {
            // Get image as bitmap
            image.lockFocus()
            let bitmapRepresentation = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
            image.unlockFocus()
            
            // Search file type according to the previous NSPopUpMenu selection
            var fileType: NSBitmapImageFileType = .NSPNGFileType
            
            switch savePanel!.allowedFileTypes![0] as! String {
            case "png":
                fileType = NSBitmapImageFileType.NSPNGFileType
            case "jpg":
                fileType = NSBitmapImageFileType.NSJPEGFileType
            default:
                fileType = .NSPNGFileType;
            }
            
            var temp: [NSObject: AnyObject] = [NSObject: AnyObject]()
            
            // Convert bitmap to data
            let data: NSData? = bitmapRepresentation!.representationUsingType(fileType, properties: temp) as NSData?
            
            // Save data to selected file
            data!.writeToFile(savePanel!.URL!.path!, atomically: false)
        }
    }
    
    func dropMenuChange(sender: NSPopUpButton) {
        let extensions: [String] = [sender.selectedItem!.title]
        savePanel!.allowedFileTypes = extensions
    }
    
    func windowWillClose(notification: NSNotification) {
        // Free some resources
        backgroundImage = nil
        imageView!.releaseImage()
        selectedImage = nil
    }
    
    func saveImage() {
        savePicture(selectedImage!)
        closeWindow()
    }
    
    func uploadImage()  {
        if imgurClient!.hasAccount() == true {
            // If has account, upload it and close
            imgurClient!.uploadImage(selectedImage!)
        } else {
            // Else, check if the user wants anonymously uploads
            let defaults = NSUserDefaults.standardUserDefaults()
            if defaults.boolForKey("upload_anonymously") {
                // If yes, upload it
                imgurClient!.uploadImage(selectedImage!)
            } else {
                // Else, ask
                confirmAnonymous = ConfirmAnonymousUploadPanelController()
                window!.level = 2
                let result = NSApp.runModalForWindow(confirmAnonymous!.window!)
                
                if result == NSOKButton {
                    imgurClient!.uploadImage(selectedImage!)
                }
            }
        }
        closeWindow()
    }
    
    func closeWindow() {
        if selectActionView != nil {
            selectActionView!.view.removeFromSuperview()
        }
        close()
    }
    
}
