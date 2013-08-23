//
//  FriendsViewController.h
//  ChatTest
//
//  Created by siteview_mac on 13-7-11.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPChatDelegate.h"
#import "LoginViewController.h"

@interface FriendsViewController : UIViewController<GMSMapViewDelegate, XMPPChatDelegate>

@property (nonatomic, strong) NSString *roomName;

- (void)addCoordinate:(CLLocationCoordinate2D)coordinate;

@end