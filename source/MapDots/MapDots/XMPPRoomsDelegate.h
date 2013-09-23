//
//  XMPPRoomsDelegate.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-18.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPRoom.h"

@protocol XMPPRoomsDelegate <NSObject>

@optional

-(void)newRoomsReceived:(XMPPRoom *)roomsContent;

- (void)didJoinRoomSuccess:(NSString *)roomJid;
- (void)didJoinRoomFailure:(NSString *)errorMsg;

@end
