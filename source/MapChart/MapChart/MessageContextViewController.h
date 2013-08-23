//
//  RoomMessageViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-24.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoomMessageDelegate.h"

@interface MessageContextViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, XMPPRoomMessageDelegate>

@property (nonatomic, strong) NSString *roomName;

- (void)didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID;

- (void)newMessageReceived:(NSArray *)array from:(NSString *)from to:(NSString *)to;

@end
