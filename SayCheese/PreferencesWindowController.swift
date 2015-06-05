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
    
    @IBOutlet var signInButton: NSButton!
    @IBOutlet var pinCodeTextField: NSTextField!
    @IBOutlet var savePinButton: NSButton!
    @IBOutlet var hotKeyTextField: HotkeyTextField!
    @IBOutlet var stateTextField: NSTextField!
    @IBOutlet var launchLoginCheckBox: NSButton!
    @IBOutlet var versionLabel: NSTextField!

    override init(window: NSWindow?)  {
        super.init(window: window)
        
        if self.window != nil {
            self.window!.releasedWhenClosed = false
            window!.level = 20

        }
    }
    
    required init?(coder aDecoder: NSCoder){
        
        super.init(coder: aDecoder)
        
    }
    
    
    override func showWindow(sender: AnyObject!) {
        
        super.showWindow(sender)
        if self.window != nil {
            NSBundle.mainBundle().loadNibNamed("PreferencesWindowController", owner: self, topLevelObjects: nil)
        }
        
        self.window?.level = 20
        self.window?.makeKeyAndOrderFront(self)
        self.window?.makeFirstResponder(launchLoginCheckBox!)
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        
        println("HasAccount: \(imgurClient!.hasAccount()!)")
        
        
        if imgurClient!.hasAccount()! {
            pinCodeTextField!.enabled = false
            stateTextField.stringValue = "Logged successfully into Imgur."
            signInButton.title = "Sign out"
        } else {
            stateTextField.stringValue = "You haven't logged into Imgur yet."
        }
        
        let startUpUtil = StartUpUtils()
        if startUpUtil.isAppALoginItem() {
            if launchLoginCheckBox != nil {
                launchLoginCheckBox!.state = NSOnState
            }
        } else {
            if launchLoginCheckBox != nil {
                launchLoginCheckBox!.state = NSOffState
            }
        }
        
        if versionLabel != nil {
            let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
            versionLabel!.stringValue = "SayCheese \(version)"
        }
        
    }
    
    
    @IBAction func toggleImgurAccount(sender: AnyObject) {
        
        if imgurClient!.hasAccount()! {
            signOut()
        } else {
            pinCodeTextField.enabled = true
            stateTextField.stringValue = "You haven't logged into Imgur yet."
            imgurClient!.authenticate(false)
        }
        
        
    }
    
    @IBAction func codeWritten(sender: AnyObject?) {
        let code = pinCodeTextField.stringValue
        savePinButton!.enabled = false
        NSLog(code)
        imgurClient!.imgurSession!.authenticateWithCode(code)
    }
    
    func authenticationInImgurSuccessful() {
        pinCodeTextField.enabled = false
        signInButton.title = "Sign out"
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
    
    func signOut(){
        pinCodeTextField.enabled = false
        stateTextField.stringValue = "You haven't logged into Imgur yet."
        signInButton.title = "Sign in"
        
        imgurClient!.signOut()
        
    }
    
    func activatePinButton() {
        savePinButton!.enabled = true
    }
    
    
    
}
