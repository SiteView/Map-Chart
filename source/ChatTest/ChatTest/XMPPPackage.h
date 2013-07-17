//
//  XMPPPackage.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-11.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPPackage : NSObject
//+ (XMPPPackage*)sharedInstance;
@property (nonatomic, assign) id authenticateDelegate;

- (BOOL)connect:(NSString *)userId password:(NSString *)password server:(NSString *)server;

@end
