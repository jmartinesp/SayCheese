//
//  HotkeyTextField.swift
//  SayCheese
//
//  Created by Arasthel on 15/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Cocoa

class HotkeyTextField: NSTextField {
    
    var canEdit = false
    
    var hotKeysDelegate: ChangeHotKeysDelegate?
    
    var monitor: AnyObject?
    
    var stringResult = ""
    
    var firstOpening = true
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
        // Initialization code here.
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if firstOpening == false {
            if(ok) {
                canEdit = true
                monitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask|NSEventMask.FlagsChangedMask, handler: keyPressed)
            }
        }
        
        firstOpening = false
        
        return ok
    }
    
    override func textShouldBeginEditing(textObject: NSText) -> Bool {
        return false
    }
    
    func keyPressed(event: NSEvent!) -> NSEvent {
        
        if canEdit {
        
            let hasModifier = (event.modifierFlags.rawValue & (NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue |
                NSEventModifierFlags.ControlKeyMask.rawValue | NSEventModifierFlags.ShiftKeyMask.rawValue | NSEventModifierFlags.FunctionKeyMask.rawValue)) > 0
            
            if hasModifier {
                setTextWithKeyCode(Int(event.keyCode), andFlags: event.modifierFlags.rawValue, eventType: event.type)
            }
        }
        
        return event
    }
    
    func setTextWithKeyCode(keyCode: Int, andFlags flags: UInt, eventType: NSEventType?) {
        var resultString = ""
        
        let modifierFlags = NSEventModifierFlags(flags)
        
        if  (modifierFlags & NSEventModifierFlags.CommandKeyMask).rawValue != 0 {
            resultString += "⌘+"
        }
        
        if (modifierFlags & NSEventModifierFlags.AlternateKeyMask).rawValue != 0 {
            resultString += "⎇+"
        }
        
        if (modifierFlags & NSEventModifierFlags.ControlKeyMask).rawValue != 0 {
            resultString += "^+"
        }
        
        if (modifierFlags & NSEventModifierFlags.ShiftKeyMask).rawValue != 0 {
            resultString += "⇧+"
        }
        
        if (modifierFlags & NSEventModifierFlags.FunctionKeyMask).rawValue != 0 {
            resultString += "fn+"
        }
        
        if (eventType? != nil) {
            if eventType == NSEventType.KeyDown {
                let char = HotKeyUtilsWrapper.getStringFromKeyCode(UInt16(keyCode))[0]
                resultString += char
                stringValue = resultString
                canEdit = false
                window!.endEditingFor(self)
                NSEvent.removeMonitor(monitor!)
                
                if (hotKeysDelegate? != nil) {
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC));
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                            self.hotKeysDelegate!.changeHotKeysToKeyCode(UInt16(keyCode), flags: flags)
                        })
                    
                }
                
            } else {
                stringValue = resultString
            }
        } else {
            let char = HotKeyUtilsWrapper.getStringFromKeyCode(UInt16(keyCode))[0]
            resultString += char
            stringValue = resultString
        }
    }
}
