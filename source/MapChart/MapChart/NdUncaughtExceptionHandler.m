//
//  NdUncaughtExceptionHandler.m
//  MapChart
//
//  Created by siteview_mac on 13-8-22.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import "NdUncaughtExceptionHandler.h"

@implementation NdUncaughtExceptionHandler

NSString *applicationDocumentsDirectory()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception)
{
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *url = [NSString stringWithFormat:@"=============Exception Report==================\nName:%@\nReason:%@\nCallStackSymbols:%@",
                     name, reason, [arr componentsJoinedByString:@"\n"]];
    NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

+ (NSUncaughtExceptionHandler *)getHandler
{
    return NSGetUncaughtExceptionHandler();
}
@end
