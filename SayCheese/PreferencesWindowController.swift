//
//  PreferencesViewController.swift
//  SayCheese
//
//  Created by Arasthel on 15/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, ReceivedImgurAuthenticationDelegate {
    
    var imgurClient: ImgurClient?
    
    @IBOutlet var pinCodeTextField: NSTextField
    @IBOutlet var savePinButton: NSButton
    @IBOutlet var hotKeyTextField: HotkeyTextField
    @IBOutlet var stateTextField: NSTextField
    @IBOutlet var launchLoginCheckBox: NSButton
    @IBOutlet var versionLabel: NSTextField

    init() {
        super.init()
    }
    
    init(window: NSWindow?)  {
        super.init(window: window)
        if self.window? {
            self.window!.releasedWhenClosed = false
        }
    }
    
    override func showWindow(sender: AnyObject!) {
        super.showWindow(sender)
        if !self.window {
            NSBundle.loadNibNamed("PreferencesWindowController", owner: self)
        }
        
        self.window!.level = 20
        self.window!.makeKeyAndOrderFront(self)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        self.window!.makeFirstResponder(launchLoginCheckBox!)
        
        if imgurClient!.hasAccount() == true {
            pinCodeTextField.enabled = false
            stateTextField.stringValue = "Logged successfully into Imgur."
        } else {
            stateTextField.stringValue = "You haven't logged into Imgur yet."
        }
        
        let startUpUtil = StartUpUtils()
        if startUpUtil.isAppALoginItem() == true {
            if launchLoginCheckBox? {
                launchLoginCheckBox!.state = NSOnState
            }
        } else {
            if launchLoginCheckBox? {
                launchLoginCheckBox!.state = NSOffState
            }
        }
        
        if versionLabel? {
            let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
            versionLabel!.stringValue = "SayCheese \(version)"
        }
        
    }
    
    
    @IBAction func toggleImgurAccount(sender: AnyObject) {
        pinCodeTextField.enabled = true
        stateTextField.stringValue = "You haven't logged into Imgur yet."
        imgurClient!.authenticate(false)
    }
    
    @IBAction func codeWritten(sender: AnyObject?) {
        let code = pinCodeTextField.stringValue
        savePinButton!.enabled = false
        NSLog(code)
        imgurClient!.imgurSession!.authenticateWithCode(code)
    }
    
    func authenticationInImgurSuccessful() {
        pinCodeTextField.enabled = false
        stateTextField.stringValue = "Logged successfully into Imgur."
    }
    
    @IBAction func toggleLaunchOnBoot(sender: NSButton?) {
        let startUpUtil = StartUpUtils()
        if startUpUtil.isAppALoginItem() == false {
            startUpUtil.addAppAsLoginItem()
        } else {
            startUpUtil.deleteAppFromLoginItem()
        }
    }
    
    func activatePinButton() {
        savePinButton!.enabled = true
    }
    
    
    
}
