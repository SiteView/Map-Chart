//
//  XMPPChatDelegate.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-12.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMPPChatDelegate <NSObject>

@optional

-(void)newBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color;
-(void)buddyWentOffline:(NSString *)buddyName;
- (void)updateBuddyOnline:(NSString *)buddyName coordinate:(CLLocationCoordinate2D)coordinate color:(UIColor *)color;

@end
