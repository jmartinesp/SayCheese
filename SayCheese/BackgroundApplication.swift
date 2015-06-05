//
//  BackgroundApplication.swift
//  SayCheese
//
//  Created by Arasthel on 15/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Foundation

class BackgroundApplication: NSObject, ChangeHotKeysDelegate, UploadDelegate {
    
    var statusItem: NSStatusItem?
    var deleteLastImageItem: NSMenuItem?
    var screenshotWindow: ScreenshotWindow?
    var settingsController: PreferencesWindowController?
    var showing = false
    
    var flags: NSEventModifierFlags?
    var keyCode: UInt16?
    
    var imgurClient: ImgurClient?
    
    
    override init() {
        super.init()
        
        // Configure statusbar
        var statusBar = NSStatusBar.systemStatusBar()
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        statusItem!.image = NSImage(named: "menubar_icon_inactive")
        statusItem!.toolTip = "SayCheese"
        statusItem!.highlightMode = true
        
        // Add menu to statusbar icon
        let menu = NSMenu()
        menu.autoenablesItems = false
        statusItem!.menu = menu
        
        // Add take pic item
        var takePicItem = menu.addItemWithTitle("Take screenshot", action: "takePicture:", keyEquivalent:"<")
        takePicItem!.keyEquivalentModifierMask = (Int(NSEventModifierFlags.CommandKeyMask.rawValue) | Int(NSEventModifierFlags.ShiftKeyMask.rawValue))
        takePicItem!.target = self
        
        var settingsItem = menu.addItemWithTitle("Settings", action: "openSettings:", keyEquivalent:"")
        settingsItem!.target = self
        
        deleteLastImageItem = menu.addItemWithTitle("Delete last image", action: "deleteLastImage", keyEquivalent: "")
        deleteLastImageItem!.enabled = false
        deleteLastImageItem!.target = self
        
        // Add quit app item
        var quitAppItem = menu.addItemWithTitle("Quit", action: "quitApp:", keyEquivalent:"")
        quitAppItem!.target = self
        
        // Load saved keyCode and flags
        _loadDefaults(nil)
        
        // Check if the app has accessibility permissions
        if AXIsProcessTrustedWithOptions(nil) == 1 {
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            // If first boot, show info alert
            if !userDefaults.boolForKey("tutorial_passed") {
                let alert = NSAlert()
                alert.addButtonWithTitle("Accept")
                alert.messageText = "Hi! Thanks for using SayCheese."
                alert.informativeText = "To take a screenshot use ⌘+⇧+<. You can change the hotkeys later in Settings."
                alert.alertStyle = NSAlertStyle.InformationalAlertStyle
                
                alert.runModal()
                
                userDefaults.setBool(true, forKey: "tutorial_passed")
                userDefaults.synchronize()
            }
            
            // If it can access, register listeners
            NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyUpMask, handler: takePictureKeyPressed)
            NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyUpMask, handler: quitScreenWindow)
            
            
        } else {
            // Else, open dialog and close app
            let alert = NSAlert()
            alert.messageText = "SayCheese needs permission to use the accessibility API."
            alert.informativeText = "Once you have permission, please launch the application again."
            alert.addButtonWithTitle("Accept")
            alert.runModal()
            
            NSWorkspace.sharedWorkspace().openFile("/System/Library/PreferencePanes/Security.prefPane")
            
            NSApplication.sharedApplication().terminate(self)
        }
        
        imgurClient = ImgurClient(uploadDelegate: self)
        
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC));
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                if self.imgurClient!.hasAccount() == true {
                    self.imgurClient!.authenticate(true)
                }
            })
    }
    
    
    func openSettings(sender: AnyObject?) {
        if settingsController == nil {
            settingsController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
            settingsController!.imgurClient = imgurClient
            imgurClient!.authenticationDoneDelegate = settingsController
        }
        
        settingsController!.showWindow(self)
        
        settingsController!.hotKeyTextField.hotKeysDelegate = self
        
        _loadDefaults(settingsController)
    }
    
    func _loadDefaults(settingsController: PreferencesWindowController?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("keyCode") != nil && defaults.objectForKey("flags") != nil) {
            var intKeyCode = defaults.integerForKey("keyCode")
            var flagsData = defaults.integerForKey("flags")
            
            keyCode = UInt16(intKeyCode)
            flags = NSEventModifierFlags(UInt(flagsData))

        } else {
            // If there aren't custom hotkeys, use Cmd+Alt+<
            keyCode = UInt16(50)
            flags = NSEventModifierFlags(1179914)
        }
        
        if settingsController != nil {
            settingsController!.hotKeyTextField.setTextWithKeyCode(Int(keyCode!), andFlags: flags!.rawValue, eventType: nil)
        }

    }
    
    func changeHotKeysToKeyCode(keyCode: UInt16, flags: UInt) {
        self.keyCode = keyCode
        self.flags = NSEventModifierFlags(flags)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let intKeyCode = Int(keyCode)
        let flagsData = Int(flags)
        
        defaults.setInteger(intKeyCode, forKey: "keyCode")
        defaults.setInteger(flagsData, forKey: "flags")
        defaults.synchronize()
    }
    
    func quitApp(sender: AnyObject!) {
        NSApplication.sharedApplication().terminate(sender)
    }
    
    func quitScreenWindow(event: NSEvent!) -> NSEvent {
        let modifierFlags = event.modifierFlags
        if modifierFlags == flags {
            if event.keyCode == keyCode {
                takePicture(nil)
            }
        } else if event.keyCode == 53 {
            self.screenshotWindow?.close()
        }
        return event
    }
    
    func takePictureKeyPressed(event: NSEvent!) {
        let modifierFlags = event.modifierFlags
        if (modifierFlags == flags) {
            if event.keyCode == keyCode {
                takePicture(nil)
            }
        } else if event.keyCode == 53 {
            self.screenshotWindow?.close()
        }
    }
    
    func uploadStarted(){
        statusItem!.image = NSImage(named: "menubar_icon")
    }
    
    func uploadFinished(){
        statusItem!.image = NSImage(named: "menubar_icon_inactive")
        if !deleteLastImageItem!.enabled {
            deleteLastImageItem!.enabled = true
        }
    }
    
    func deleteLastImage(){
        imgurClient!.deleteLastImage()
    }
    
    func imageDeleted(){
        deleteLastImageItem!.enabled = false
    }
    
    func takePicture(object: AnyObject?) {
        system("screencapture -c -x");
        let imageFromClipboard = NSImage(pasteboard: NSPasteboard.generalPasteboard())
        
        let windowRect = NSMakeRect(0, 0, NSScreen.mainScreen()!.frame.size.width, NSScreen.mainScreen()!.frame.size.height)
        
        if screenshotWindow == nil {
            screenshotWindow = ScreenshotWindow(window: NSWindow(contentRect: windowRect, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.Buffered, defer: false))
            screenshotWindow!.imgurClient = imgurClient
        }
        
        screenshotWindow!.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
        
        let windowSize = NSSizeFromCGSize(CGSize(width: NSScreen.mainScreen()!.frame.size.width, height: NSScreen.mainScreen()!.frame.size.height))
        
        self.screenshotWindow!.paintImage(imageFromClipboard!, withSize: windowSize)
    }

    
}
