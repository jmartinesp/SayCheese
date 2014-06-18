//
//  HotKeyUtilsWrapper.m
//  SayCheese
//
//  Created by Arasthel on 15/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "HotKeyUtilsWrapper.h"
#import "HotKeyUtilities.h"

@implementation HotKeyUtilsWrapper

+ (NSString *)getStringFromKeyCode:(CGKeyCode)keyCode {
    return (__bridge NSString *)(createStringForKey(keyCode));
}

@end