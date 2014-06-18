//
//  ChangeHotKeysDelegate.swift
//  SayCheese
//
//  Created by Arasthel on 15/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Foundation

protocol ChangeHotKeysDelegate {
    
    func changeHotKeysToKeyCode(keyCode: UInt16, flags: UInt)
    
}
