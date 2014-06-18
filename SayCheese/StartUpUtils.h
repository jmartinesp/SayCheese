//
//  StartUpUtils.h
//  SayCheese
//
//  Created by Arasthel on 17/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartUpUtils : NSObject

-(void) addAppAsLoginItem;
-(void) deleteAppFromLoginItem;
-(BOOL) isAppALoginItem;

@end