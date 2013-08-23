//
//  NdUncaughtExceptionHandler.h
//  MapChart
//
//  Created by siteview_mac on 13-8-22.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NdUncaughtExceptionHandler : NSObject

+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler*)getHandler;

@end
