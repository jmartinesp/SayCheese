//
//  ScreenshotDelegate.swift
//  SayCheese
//
//  Created by Jorge Martín Espinosa on 14/6/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Foundation

protocol ScreenshotDelegate {
    
    func regionSelected(image: NSImage)
    
    func saveImage();
    
    func uploadImage();
    
    func closeWindow();
}
