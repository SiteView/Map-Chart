//
//  XMPPRoomMessageDelegate.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-24.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@protocol XMPPRoomMessageDelegate <NSObject>

- (void)didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID;

- (void)newMessageReceived:(NSArray *)array from:(NSString *)from to:(NSString *)to;

@end
