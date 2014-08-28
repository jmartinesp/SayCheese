//
//  UploadDelegate.swift
//  SayCheese
//
//  Created by Dexafree on 28/08/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Foundation

protocol UploadDelegate {
    
    func uploadStarted()
    
    func uploadFinished()
    
    func imageDeleted()
    
}