//
//  XMPPCreateRoomDelegate.h
//  ChatTest
//
//  Created by siteview_mac on 13-8-13.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMPPCreateRoomDelegate <NSObject>

- (void)didCreateRoomSuccess;
- (void)didCreateRoomFailure:(NSString *)errorMsg;

@end
