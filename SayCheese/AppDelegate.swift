//
//  AppDelegate.swift
//  SayCheese
//
//  Created by Jorge Martín Espinosa on 13/6/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var backgroundApplication: BackgroundApplication?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        backgroundApplication = BackgroundApplication()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

