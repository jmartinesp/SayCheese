//
//  HotKeyUtilsWrapper.h
//  SayCheese
//
//  Created by Arasthel on 15/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HotKeyUtilsWrapper : NSObject 

+ (NSString *)getStringFromKeyCode:(CGKeyCode)keyCode;

@end